library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

# 1. Make a graph
graph <- DiagrammeR::grViz("
digraph {
graph [layout = dot, rankdir = TD]

node [
shape = box, 
style = filled, 
fillcolor = white, 
fontname = Helvetica,
penwidth = 2.0] 

edge [arrowhead = diamond]

A [label = 'EXPLORATORY \nANALYSIS OF \nMICROBIOME DATA', fillcolor = white, penwidth = 5.0]
B [label = 'Preprocesed\nTidy Objects']
C [label = 'Data Visualization']
D [label = 'Data Distribution']
E [label = 'Barcharts']
F [label = 'Boxplots']
G [label = 'Heatmaps']
H [label = 'Correlation']


{A}  -> B [label = '  Input Data']
{B}  -> C
{C}  -> D
{D}  -> E
{D}  -> F
{C}  -> H
{H}  -> G


}", height = 500, width = 500)

# 2. Convert to SVG, then save as png
part4_flow = DiagrammeRsvg::export_svg(graph)
part4_flow = charToRaw(part4_flow) # flatten
rsvg::rsvg_png(part4_flow, "img/part4_flow.png")

