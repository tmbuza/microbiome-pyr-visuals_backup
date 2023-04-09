library(phyloseq)
library(tidyverse)

source("workflow/scripts/common.R")

# qiime2R::function from: https://rdrr.io/github/denalitherapeutics/archs4/f/
###########################################

#------------------------------------
# read_q2biom
#------------------------------------
read_q2biom <- function(file) {
  if(missing(file)){stop("Path to biom file given")}
  if(!file.exists(file)){stop("File not found")}
  
  hdata<-h5read(file,"/")
  
  ftable<-
    sparseMatrix(
      p=hdata$observation$matrix$indptr,
      j=hdata$observation$matrix$indices,
      x=as.numeric(hdata$observation$matrix$data),
      index1=FALSE,
      dims=c(length(hdata$observation$ids), length(hdata$sample$ids)),
      dimnames=list(hdata$observation$ids,hdata$sample$ids)
    )
  
  return(as.matrix(ftable))
}


#------------------------------------
# read_q2metadata
#------------------------------------

read_qza <- function(file, tmp, rm) {
  
  if(missing(tmp)){tmp <- tempdir()}
  if(missing(file)){stop("Path to artifact (.qza) not provided.")}
  if(!file.exists(file)){stop("Input artifact (",file,") not found. Please check path and/or use list.files() to see files in current working directory.")}
  if(missing(rm)){rm=TRUE} #remove the decompressed object from tmp
  if(!grepl("qza$", file)){stop("Provided file is not qiime2 artifact (.qza).")}
  
  
  
  unzip(file, exdir=tmp) 
  unpacked<-unzip(file, exdir=tmp, list=TRUE)
  
  artifact<-read_yaml(paste0(tmp,"/", paste0(gsub("/..+","", unpacked$Name[1]),"/metadata.yaml"))) #start by loading in the metadata not assuming it will be first file listed
  artifact$contents<-data.frame(files=unpacked)
  artifact$contents$size=sapply(paste0(tmp, "/", artifact$contents$files), file.size)
  artifact$version=read.table(paste0(tmp,"/",artifact$uuid, "/VERSION"))
  
  
  #get data dependent on format
  if(grepl("BIOMV", artifact$format)){
    artifact$data<-read_q2biom(paste0(tmp, "/", artifact$uui,"/data/feature-table.biom"))
  } else if (artifact$format=="NewickDirectoryFormat"){
    artifact$data<-read.tree(paste0(tmp,"/",artifact$uuid,"/data/tree.nwk"))
  } else if (artifact$format=="DistanceMatrixDirectoryFormat") {
    artifact$data<-as.dist(read.table(paste0(tmp,"/", artifact$uuid, "/data/distance-matrix.tsv"), header=TRUE, row.names=1, fill= TRUE))
  } else if (grepl("StatsDirFmt", artifact$format)) {
    if(paste0(artifact$uuid, "/data/stats.csv") %in% artifact$contents$files.Name){artifact$data<-read.csv(paste0(tmp,"/", artifact$uuid, "/data/stats.csv"), header=TRUE, row.names=1)}
    if(paste0(artifact$uuid, "/data/stats.tsv") %in% artifact$contents$files.Name){artifact$data<-read.table(paste0(tmp,"/", artifact$uuid, "/data/stats.tsv"), header=TRUE, row.names=1, sep='\t')} #can be tsv or csv
  } else if (artifact$format=="TSVTaxonomyDirectoryFormat"){
    artifact$data<-read.table(paste0(tmp,"/", artifact$uuid, "/data/taxonomy.tsv"), sep='\t', header=TRUE, quote="", comment="")
  } else if (artifact$format=="OrdinationDirectoryFormat"){
    artifact$data<-suppressWarnings(readLines(paste0(tmp,"/", artifact$uuid, "/data/ordination.txt")))
    artifact<-parse_ordination(artifact, tmp)
  } else if (artifact$format=="DNASequencesDirectoryFormat") {
    artifact$data<-readDNAStringSet(paste0(tmp,"/",artifact$uuid,"/data/dna-sequences.fasta"))
  } else if (artifact$format=="AlignedDNASequencesDirectoryFormat") {
    artifact$data<-readDNAMultipleAlignment(paste0(tmp,"/",artifact$uuid,"/data/aligned-dna-sequences.fasta"))
  } else if (grepl("EMPPairedEndDirFmt|EMPSingleEndDirFmt|FastqGzFormat|MultiplexedPairedEndBarcodeInSequenceDirFmt|MultiplexedSingleEndBarcodeInSequenceDirFmt|PairedDNASequencesDirectoryFormat|SingleLanePerSamplePairedEndFastqDirFmt|SingleLanePerSampleSingleEndFastqDirFmt", artifact$format)) {
    artifact$data<-data.frame(files=list.files(paste0(tmp,"/", artifact$uuid,"/data")))
    artifact$data$size<-format(sapply(artifact$data$files, function(x){file.size(paste0(tmp,"/",artifact$uuid,"/data/",x))}, simplify = TRUE))
  } else if (artifact$format=="AlphaDiversityDirectoryFormat") {
    artifact$data<-read.table(paste0(tmp, "/", artifact$uuid, "/data/alpha-diversity.tsv"))
  } else if (artifact$format=="DifferentialDirectoryFormat") {
    defline<-suppressWarnings(readLines(paste0(tmp, "/", artifact$uuid, "/data/differentials.tsv"))[2])
    defline<-strsplit(defline, split="\t")[[1]]
    defline[grep("numeric", defline)]<-"double"
    defline[grep("categorical|q2:types", defline)]<-"factor"
    coltitles<-strsplit(suppressWarnings(readLines(paste0(tmp, "/", artifact$uuid, "/data/differentials.tsv"))[1]), split='\t')[[1]]
    artifact$data<-read.table(paste0(tmp, "/", artifact$uuid, "/data/differentials.tsv"), header=F, col.names=coltitles, skip=2, sep='\t', colClasses = defline, check.names = FALSE)
    colnames(artifact$data)[1]<-"Feature.ID"
  } else {
    message("Format not supported, only a list of internal files and provenance is being imported.")
    artifact$data<-list.files(paste0(tmp,"/",artifact$uuid, "/data"))
  }
  
  #Add Provenance
  pfiles<-paste0(tmp,"/", grep("..+provenance/..+action.yaml", unpacked$Name, value=TRUE))
  artifact$provenance<-lapply(pfiles, read_yaml)
  names(artifact$provenance)<-grep("..+provenance/..+action.yaml", unpacked$Name, value=TRUE)
  
  if(rm==TRUE){unlink(paste0(tmp,"/", artifact$uuid), recursive=TRUE)}
  
  
  return(artifact)
}

#------------------------------------
# qza_to_phyloseq
#------------------------------------

qza_to_phyloseq<-function(features,tree,taxonomy,metadata, tmp){
  
  if(missing(features) & missing(tree) & missing(taxonomy) & missing(metadata)){
    stop("At least one required artifact is needed (features/tree/taxonomy/) or the metadata.")
  }
  
  if(missing(tmp)){tmp <- tempdir()}
  
  argstring<-""
  
  if(!missing(features)){
    features<-as.data.frame(read_qza(features, tmp=tmp)$data)
    argstring<-paste(argstring, "otu_table(features, taxa_are_rows=T),")
  }
  
  if(!missing(taxonomy)){
    taxonomy<-read_qza(taxonomy, tmp=tmp)$data
    taxonomy<-parse_taxonomy(taxonomy)
    taxonomy<-as.matrix(taxonomy)
    argstring<-paste(argstring, "tax_table(taxonomy),")
  }
  
  if(!missing(tree)){
    tree<-read_qza(tree, tmp=tmp)$data
    argstring<-paste(argstring, "phy_tree(tree),")
  }
  
  if(!missing(metadata)){
    if(is_q2metadata(metadata)){
      metadata<-read_q2metadata(metadata)
      rownames(metadata)<-metadata$SampleID
      metadata$SampleID<-NULL
    } else{
      metadata<-read.table(metadata, row.names=1, sep='\t', quote="", header=TRUE)
    }
    argstring<-paste(argstring, "sample_data(metadata),")
  }
  
  argstring<-gsub(",$","", argstring) #remove trailing ","
  
  physeq<-eval(parse(text=paste0("phyloseq(",argstring,")")))
  
  return(physeq)
}


#------------------------------------
# read_q2metadata
#------------------------------------

read_q2metadata <- function(file) {
  if(missing(file)){stop("Path to metadata file not found")}
  if(!is_q2metadata(file)){stop("Metadata does not define types (ie second line does not start with #q2:types)")}
  
  defline<-suppressWarnings(readLines(file)[2])
  defline<-strsplit(defline, split="\t")[[1]]
  
  defline[grep("numeric", tolower(defline))]<-"double"
  defline[grep("categorical|q2:types", tolower(defline))]<-"factor"
  defline[defline==""]<-"factor"
  
  coltitles<-strsplit(suppressWarnings(readLines(file)[1]), split='\t')[[1]]
  metadata<-read.table(file, header=F, col.names=coltitles, skip=2, sep='\t', colClasses = defline, check.names = FALSE)
  colnames(metadata)[1]<-"SampleID"
  
  return(metadata)
}


#------------------------------------
# write_q2manifest
#------------------------------------
write_q2manifest<-function(outfile, directory, extension, paired, Fwd, Rev){
  if(missing(outfile)){outfile<-paste0("q2manifest_", gsub(" |:","", timestamp(prefix="", suffix="")),".txt")}
  if(missing(directory)){stop("Directory containing reads not provided.")}
  if(missing(extension)){extension=".fastq.gz"}
  if(missing(paired)){paired=FALSE}
  if(missing(Fwd)){Fwd="_R1"}
  if(missing(Rev)){Rev="_R2"}
  
  files<-list.files(directory, pattern=gsub("\\.", "\\.", extension))
  
  if(!paired){
    output<-data.frame(`sample-id`=gsub(gsub("\\.", "\\.", extension), "", files), `absolute-filepath`=paste0(getwd(), "/", files), check.names = FALSE)
    write.table(output, file=outfile, row.names=F, quote=F, sep="\t")
  } else {
    output<-data.frame(`sample-id`=gsub(gsub("\\.", "\\.", extension), "", files), file=paste0(getwd(), "/", files), check.names = FALSE)
    output$Read<-case_when(
      grepl(Fwd, output$file)~"forward-absolute-filepath",
      grepl(Rev, output$file)~"reverse-absolute-filepath",
      TRUE~"Error"
    )
    if(!sum(grep("Error", output$Read))==0){stop("Could not assign all reads to forward or reverse in paired mode.")}
    output$`sample-id`<-gsub(Fwd, "", output$`sample-id`)
    output$`sample-id`<-gsub(Rev, "", output$`sample-id`)
    output<-spread(output, key=Read, value=file)
    write.table(output, file=outfile, row.names=F, quote=F, sep="\t")
  }
  
  message("Manifest written to", outfile)
}


#------------------------------------
# subsample_table
#------------------------------------

subsample_table<-function(features, depth, seed, with_replace, verbose){
  if(missing(verbose)){verbose=T} 
  if(missing(depth)){depth=min(colSums(features))}
  if(missing(with_replace)){with_replace=FALSE}
  if(missing(seed)){seed=182}
  
  if(verbose==T){message(paste("Subsampling feature table to", depth, ", currently has ", nrow(features), " taxa."))}
  sub<-as.data.frame(rarefy_even_depth(otu_table(features, taxa_are_rows = T), sample.size=depth, rngseed=seed, replace=with_replace, verbose = FALSE))
  if(verbose==T){message(paste("...after subsampling there are", nrow(sub), "taxa with",round(sum(sub)/sum(features),4)*100, "% of reads retained from", ncol(sub),"of",ncol(features),"samples."))}
  return(sub)
}


#------------------------------------
# summarize_taxa
#------------------------------------

summarize_taxa <- function(features, taxonomy) {
  
  taxlevels<-c("Kingdom","Phylum","Class","Order","Family","Genus","Species")
  
  if(missing(features)){stop("Feature table not provided")}
  if(missing(taxonomy)){stop("taxonomy table not provided")}
  if(sum(colnames(taxonomy) %in% taxlevels)!=7){stop("Taxonomy does not contain expected columns containing Kingdom,Phylum,Class,Order,Family,Genus,Species.")}  
  
  output<-list()
  
  for(lvl in taxlevels){
    suppressMessages(
      output[[lvl]]<-
        features %>%
        as.data.frame() %>%
        rownames_to_column("FeatureID") %>%
        gather(-FeatureID, key="SampleID", value="Counts") %>%
        left_join(
          taxonomy %>% 
            rownames_to_column("FeatureID") %>%
            unite("Taxon", taxlevels[1:grep(lvl, taxlevels)], sep="; ") %>%
            select(FeatureID, Taxon)
        ) %>%
        group_by(SampleID, Taxon) %>%
        summarise(Counts=sum(Counts)) %>%
        ungroup() %>%
        spread(key=SampleID, value=Counts) %>%
        as.data.frame() %>%
        column_to_rownames("Taxon")
    )
  }
  return(output)
}


#------------------------------------
# parse_ordination
#------------------------------------


parse_ordination <- function(artifact, tmp){
  if(missing(artifact)){stop("Ordination not provided.")}
  if(missing(tmp)){stop("Temp directory not passed.")}
  
  artifact$data<-artifact$data[sapply(artifact$data, function(x) x!="")]
  
  for (i in 1:length(artifact$data)){
    if(grepl("^Eigvals\\t|^Proportion explained\\t|^Species\\t|^Site\\t|^Biplot\\t|^Site constraints\\t", artifact$data[i])){
      curfile=strsplit(artifact$data[i],"\t")[[1]][1]
    } else {
      write(artifact$data[i], paste0(tmp,"/", artifact$uuid, "/data/",curfile,".tmp"), append=TRUE)
    }
  }
  
  backup<-artifact$data
  artifact$data<-list()
  for (outs in list.files(paste0(tmp,"/", artifact$uuid,"/data"), full.names = TRUE, pattern = "\\.tmp")){
    NewLab<-gsub(" ", "", toTitleCase(gsub("\\.tmp", "", basename(outs))))
    artifact$data[[NewLab]]<-read.table(outs,sep='\t', header=FALSE)
    if(NewLab %in% c("Eigvals","ProportionExplained")){colnames(artifact$data[[NewLab]])<-paste0("PC",1:ncol(artifact$data[[NewLab]]))}
    if(NewLab %in% c("Site","SiteConstraints")){colnames(artifact$data[[NewLab]])<-c("SampleID", paste0("PC",1:(ncol(artifact$data[[NewLab]])-1)))}
    if(NewLab %in% c("Species")){colnames(artifact$data[[NewLab]])<-c("FeatureID", paste0("PC",1:(ncol(artifact$data[[NewLab]])-1)))}
  }
  artifact$data$Vectors<-artifact$data$Site #Rename Site to Vectors so this matches up with the syntax used in the tutorials
  artifact$data$Site<-NULL
  return(artifact)
}


#------------------------------------
# filter_features
#------------------------------------


filter_features<-function(features, minsamples, minreads, verbose){
  if(missing(verbose)){verbose=TRUE}
  if(missing(minsamples)){minsamples=2}
  if(missing(minreads)){minreads=2}
  
  
  if(verbose==T){message(paste("Filtering features such that they are present in at least", minsamples, "samples with a total of at least", minreads, "reads."))}
  
  failreads<-rownames(features)[!rowSums(features)>=minreads]
  failsamples<-rownames(features)[(apply(features, 1, function(x) sum(x>0))>=minsamples)==FALSE]
  
  filtered<-features[!rownames(features) %in% c(failreads, failsamples),]
  
  
  if(verbose==T){message("...after filtering there are ", nrow(filtered), " of ", nrow(features)," features retaining ", round(sum(filtered)/sum(features), 4)*100,"% of reads.")}
  
  return(filtered)
}


#------------------------------------
# interactive_table
#------------------------------------

interactive_table<-function(table, nrow){
  if(missing(nrow))(nrow=10)
  dtable<-datatable(table, extensions='Buttons', filter="top", options=list(pageLength=nrow, dom='Bfrtip', buttons=c('copy','csv','excel', 'pdf') ))
  return(dtable)
}


#------------------------------------
# is_q2metadata: Check if metadata is in qiime format
#------------------------------------

is_q2metadata <- function(file){
  suppressWarnings(
    if(grepl("^#q2:types", readLines(file)[2])){return(TRUE)}else{return(FALSE)}
  )
}


#------------------------------------
# make_clr
#------------------------------------

make_clr<-function(features, prior, czm){

  if(missing(czm)){czm=FALSE}
  if(missing(prior)){prior=0.5}
  
  if(czm){
    features <- t(cmultRepl(t(features),  label=0, method="CZM", output="p-counts", suppress.print=T))
  } else {
    features<-features + prior
  }
  
  features<-apply(features,2, function(column){log2(column)-mean(log2(column))})
  return(features)
}

#------------------------------------
# make_percent
#------------------------------------

make_percent<-function(features){
  features<-apply(features,2, function(x){100*(x/sum(x))})
  return(features)
}

#------------------------------------
# make_proportion
#------------------------------------
make_proportion<-function(features){
  features<-apply(features,2, function(x){(x/sum(x))})
  return(features)
}


#------------------------------------
# parse_taxonomy
#------------------------------------


parse_taxonomy <- function(taxonomy, tax_sep, trim_extra){
  if(missing(taxonomy)){stop("Taxonomy Table not supplied.")}
  if(missing(trim_extra)){trim_extra=TRUE}
  if(missing(tax_sep)){tax_sep="; |;"}
  if(sum(colnames(taxonomy) %in% c("Feature.ID","Taxon"))!=2){stop("Table does not match expected format. ie does not have columns Feature.ID and Taxon.")}

  taxonomy<-taxonomy[,c("Feature.ID","Taxon")]
  if(trim_extra){
  taxonomy$Taxon<-gsub("[kpcofgs]__","", taxonomy$Taxon) #remove leading characters from GG
  taxonomy$Taxon<-gsub("D_\\d__","", taxonomy$Taxon) #remove leading characters from SILVA
  }
  taxonomy<-suppressWarnings(taxonomy %>% separate(Taxon, c("Kingdom","Phylum","Class","Order","Family","Genus","Species"), sep=tax_sep))
  taxonomy<-apply(taxonomy, 2, function(x) if_else(x=="", NA_character_, x)) 
  taxonomy<-as.data.frame(taxonomy)
  rownames(taxonomy)<-taxonomy$Feature.ID
  taxonomy$Feature.ID<-NULL
  return(taxonomy)  
}


#------------------------------------
# print_provenance
#------------------------------------

print_provenance<-function(artifact){
  if(missing(artifact)){stop("Artifact not provided...")}

  return(list.tree(artifact$provenance, maxcomp=1000, attr.print=FALSE))

}


#------------------------------------
# taxa_barplot
#------------------------------------

taxa_barplot<-function(features, metadata, category, normalize, ntoplot){
  
  q2r_palette<-c(
    "blue4",
    "olivedrab",
    "firebrick",
    "gold",
    "darkorchid",
    "steelblue2",
    "chartreuse1",
    "aquamarine",
    "yellow3",
    "coral",
    "grey"
  )
  
  if(missing(ntoplot) & nrow(features)>10){ntoplot=10} else if (missing(ntoplot)){ntoplot=nrow(features)}
  if(missing(normalize)){normalize<-"percent"}
  if(normalize=="percent"){features<-make_percent(features)} else if(normalize=="proportion"){features<-make_proportion(features)}
  
  if(missing(metadata)){metadata<-data.frame(SampleID=colnames(features))}
  if(!"SampleID" %in% colnames(metadata)){metadata <- metadata %>% rownames_to_column("SampleID")}
  if(!missing(category)){
    if(!category %in% colnames(metadata)){message(stop(category, " not found as column in metdata"))}
  }
  
  plotfeats<-names(sort(rowMeans(features), decreasing = TRUE)[1:ntoplot]) # extract the top N most abundant features on average
  
  suppressMessages(
    suppressWarnings(
      fplot<-
        features %>%
        as.data.frame() %>%
        rownames_to_column("Taxon") %>%
        gather(-Taxon, key="SampleID", value="Abundance") %>%
        mutate(Taxon=if_else(Taxon %in% plotfeats, Taxon, "Remainder")) %>%
        group_by(Taxon, SampleID) %>%
        summarize(Abundance=sum(Abundance)) %>%
        ungroup() %>%
        mutate(Taxon=factor(Taxon, levels=rev(c(plotfeats, "Remainder")))) %>%
        left_join(metadata)
    ))
  
  
  bplot<-
    ggplot(fplot, aes(x=SampleID, y=Abundance, fill=Taxon)) +
    geom_bar(stat="identity") +
    theme_q2r() +
    theme(axis.text.x = element_text(angle=45, hjust=1)) +
    coord_cartesian(expand=FALSE) +
    xlab("Sample") +
    ylab("Abundance")
  
  if(ntoplot<=10){bplot<-bplot+scale_fill_manual(values=rev(q2r_palette), name="")}
  
  if(!missing(category)){bplot<-bplot + facet_grid(~get(category), scales="free_x", space="free")}
  
  return(bplot)
}


#------------------------------------
# taxa_heatmap
#------------------------------------


taxa_heatmap<-function(features, metadata, category, normalize, ntoplot){
  
  if(missing(ntoplot) & nrow(features)>30){ntoplot=30} else if (missing(ntoplot)){ntoplot=nrow(features)}
  if(missing(normalize)){normalize<-"log10(percent)"}
  if(normalize=="log10(percent)"){features<-log10(make_percent(features+1))} else if(normalize=="clr"){features<-make_clr(features)}
  
  if(missing(metadata)){metadata<-data.frame(SampleID=colnames(features))}
  if(!"SampleID" %in% colnames(metadata)){metadata <- metadata %>% rownames_to_column("SampleID")}
  if(!missing(category)){
    if(!category %in% colnames(metadata)){message(stop(category, " not found as column in metdata"))}
  }
  
  plotfeats<-names(sort(rowMeans(features), decreasing = TRUE)[1:ntoplot]) # extract the top N most abundant features on average
  
  roworder<-hclust(dist(features[plotfeats,]))
  roworder<-roworder$labels[roworder$order]
  
  colorder<-hclust(dist(t(features[plotfeats,])))
  colorder<-colorder$labels[colorder$order]
  
  suppressMessages(
  suppressWarnings(
  fplot<-
    features %>%
    as.data.frame() %>%
    rownames_to_column("Taxon") %>%
    gather(-Taxon, key="SampleID", value="Abundance") %>%
    filter(Taxon %in% plotfeats) %>%
    mutate(Taxon=factor(Taxon, levels=rev(plotfeats))) %>%
    left_join(metadata) %>%
    mutate(Taxon=factor(Taxon, levels=roworder)) %>%
    mutate(SampleID=factor(SampleID, levels=colorder))
  ))

  bplot<-
    ggplot(fplot, aes(x=SampleID, y=Taxon, fill=Abundance)) +
    geom_tile(stat="identity") +
    theme_q2r() +
    theme(axis.text.x = element_text(angle=45, hjust=1)) +
    coord_cartesian(expand=FALSE) +
    xlab("Sample") +
    ylab("Feature") +
    scale_fill_viridis_c()
  
  if(!missing(category)){bplot<-bplot + facet_grid(~get(category), scales="free_x", space="free")}
  
  return(bplot)
}


#------------------------------------
# theme_q2r
#------------------------------------


theme_q2r<- function () { 
  theme_classic(base_size=8, base_family="Helvetica") +
  theme(panel.border = linewidth(color="black", size=1, fill=NA)) +
  theme(axis.line = element_blank(), strip.background = element_blank())
}

#------------------------------------
# corner
#------------------------------------


corner<-function(table, nrow, ncol){
  
  if(missing(table)){stop("Table-like object not provided")}
  if(missing(nrow)){nrow=5}
  if(missing(ncol)){ncol=5}
  
  return(table[1:nrow, 1:ncol])
}

#------------------------------------
# min_nonzero
#------------------------------------

min_nonzero<-function(data){
  if(missing(data) | !is.vector(data) | !is.numeric(data)){stop("Vector not provided, or is not a vector, or contains non-numeric entries.")}
  data<-data[!is.na(data)]
  data<-data[data!=0]
  return(min(data))
}

#------------------------------------
# mean_sd
#------------------------------------
mean_sd=function(x){data.frame(y=mean(x), ymin=mean(x)-sd(x), ymax=mean(x)+sd(x))}


#------------------------------------
# 
#------------------------------------



#------------------------------------
# 
#------------------------------------



###########################################


