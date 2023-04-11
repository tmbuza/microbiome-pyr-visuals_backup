# filter the samples
qiime feature-table filter-samples \
  --i-table resources/feature_table.qza \
  --m-metadata-file resources/sample_metadata.tsv \
  --p-where "[BodySite]='gut'" \
  --o-filtered-table data/gut-table.qza

#   qiime aldex2 aldex2 \
#     --i-table data/gut-table.qza \
#     --m-metadata-file resources/sample_metadata.tsv \
#     --m-metadata-column Subject \
#     --output-dir data/gut-test

# qiime aldex2 effect-plot \
#     --i-table gut-test/differentials.qza \
#     --o-visualization gut-test/gut_test

# qiime aldex2 extract-differences \
#     --i-table gut-test/differentials.qza \
#     --o-differentials gut-test/sig_gut \
#     --p-sig-threshold 0.1 \
#     --p-effect-threshold 0 \
#     --p-difference-threshold 0

# qiime tools export \
#     --input-path gut-test/sig_gut.qza \
#     --output-path differentially-expressed-features