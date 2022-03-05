# TODO:   Producing voucher etiquets using yamlme
# 
# Author: Miguel Alvarez
################################################################################

library(rmarkdown)
library(yamlme)

setwd("lab")

Spec <- readRDS("specimens.rds")

x <- Spec

N <- nrow(x)
format = "%d.%m.%Y"

###
x$coll_date <- format(x$coll_date, format)

x$TaxonName <- paste0("*", x$TaxonName, "*")
x$TaxonName <-gsub(" f. ", "* f. *", x$TaxonName, fixed = TRUE)
x$TaxonName <-gsub(" var. ", "* var. *", x$TaxonName, fixed = TRUE)
x$TaxonName <-gsub(" ssp. ", "* ssp. *", x$TaxonName, fixed = TRUE)

for(i in names(x)) {
  x[[i]] <- paste(x[[i]])
  x[[i]][x[[i]] == "NA"] <- ""
}

Body <- with(x, cbind(
        rep("\\centering\n\n\\normalsize", N),
        paste0("**", project_name, "** \\vspace{0.2cm}\n"),
        rep("\\raggedright\n", N),
        paste("**Familie:**", family, "\\"),
        paste("**Taxon:**", TaxonName, AuthorName, "\\"),
        rep("\\small \\vspace{0.2cm}\n\n", N),
        paste("**Land:**", name_0, "\\hspace{0.5cm} **Provinz:**",
            name_1, "\\"),
        paste("**Fundort:**", locality, "\\"),
        paste("**Standort:**", habitat, "\\"),
        paste("**Datum:**", coll_date, "\\"),
        paste("**Sammler:**", leg, "\\hspace{0.5cm} **Sammelnr.:**",
            coll_nr, "\\"),
        paste("**det.:**", det_name, "\\"),
        rep("\\vspace{0.2cm}\n", N),
        paste("**Anmerkungen:**", remarks, "\\"),
        rep("\\pagebreak", N)))

Labels <- write_rmd(
    geometry = paste(
        "paperheight=74mm",
        "paperwidth=115mm",
        "bindingoffset=0mm",
        "left=7mm",
        "right=7mm",
        "top=7mm",
        "bottom=7mm",
        "footskip=0mm", sep = ","),
    "header-includes" = c(
        "- \\usepackage[english]{babel}",
        "- \\pagenumbering{gobble}"),
    output = "pdf_document",
    body = txt_body(as.vector(t(Body))))

render_rmd(Labels, output_file = "labels")

# Next step
output_file = "labels"

frame = FALSE

Labels2 <- write_rmd(
    geometry = paste(
        "bindingoffset=0mm",
        "left=0mm",
        "right=0mm",
        "top=0mm",
        "bottom=0mm",
        "footskip=0mm", sep = ","),
    "header-includes" = c(
        "- \\usepackage{pdfpages}"),
    output = "pdf_document",
    body = paste0("\\includepdf[pages=-,nup=2x4,frame=", tolower(paste(frame)),
        "]{", output_file, ".pdf}"),
    filename = "test2.Rmd")

render_rmd(Labels2, output_file = "labels2")
