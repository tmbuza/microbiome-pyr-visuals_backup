theme_cdi <- function () { 
    theme_classic(base_size = 10, base_family = "Helvetica") + 
    theme(plot.title = element_text(size = 14, face = "bold"), hjust = 0.5) +
    theme(plot.subtitle = element_text(size = 12, hjust = 0.5)) +
    theme(axis.title = element_text(size=12, face = "bold")) +
    theme(axis.text = element_text(hjust = 1, size = 10))+
    theme(strip.text.x = element_text(size = 14)) +
    theme(axis.text.x = element_text(hjust=0.5))
}