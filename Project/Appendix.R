## ----document_preset, echo = FALSE, message = FALSE, warning = FALSE----
knitr::opts_chunk$set(tidy.opts = list(width.cutoff= 60), tidy = TRUE)


## ----A.1.1, message = FALSE, warning = FALSE---------------------------
# Loading packages being used. 
library(readr)
library(ggplot2)
library(factoextra)
library(broom)
library(sf)
library(countrycode)
library(rworldmap)


## ----A.1.2-------------------------------------------------------------
# Setting seed for consistency of results. 
set.seed(11152000)


## ----B.1---------------------------------------------------------------
# Loading the dataset into R. 
country_wise <- read_csv("country_wise_latest.csv", show_col_types = FALSE)

# Displaying names of countries.
colnames(country_wise)


## ----B.2---------------------------------------------------------------
# Renaming names of variables. 
colnames(country_wise) <- c("country", "confirmed", "deaths", "recovered", "active", "new.cases", "new.deaths", "new.recovered", "deaths100c", "recovered100c", "deaths100r", "confirmed.lastweek", "one.week.diff", "one.week.pct.inc", "who.region")


## ----B.3---------------------------------------------------------------
head(country_wise, n = 10)


## ----B.4---------------------------------------------------------------
# Checking for any missing values. 
print.noquote(paste("Contains missing values:", all(is.na(country_wise))))

# Checking for infinite values. 
for(i in 1:ncol(country_wise)) {
  print.noquote(paste(paste(colnames(country_wise)[i], "contains infinite values: "), !all(!is.infinite(country_wise[[i]]))))
}


## ----B.5.1-------------------------------------------------------------
# Subsetting countries with infinite values in the deaths100r variable.
subset(country_wise, subset = is.infinite(country_wise$deaths100r))[, c(1, 2, 4, 11)]


## ----B.5.2-------------------------------------------------------------
# Replacing the infinite values with 0. 
country_wise[, 11] <- ifelse(!is.finite(country_wise$deaths100r), 0, country_wise$deaths100r)

# Running test to check for any infinite values in the dataset.
for(i in 1:ncol(country_wise)) {
  print.noquote(paste(paste(colnames(country_wise)[i], "contains infinite values: "), !all(!is.infinite(country_wise[[i]]))))
}


## ----C.1.1-------------------------------------------------------------
# Displaying countries from dataset used in this analysis. 
analysis_bar <- barplot(table(country_wise$who.region), 
        main = "WHO Region (Updated Dataset)", 
        ylab = "Number of Countries",
        col = c("goldenrod", "darkorchid2", "deeppink2", "darkturquoise", "chartreuse3", "coral"),
        cex.names = 0.59, 
        ylim = c(0, 65))
text(x = c(0.7, 1.9, 3.1, 4.3, 5.5, 6.7), y = table(country_wise$who.region) + 4, labels = as.character(table(country_wise$who.region)))
legend(x = "topright", legend = c("Africa", "Americas", "Eastern Mediterranean", "Europe", "South-East Asia", "Western Pacific"), fill = c("goldenrod", "darkorchid2", "deeppink2", "darkturquoise", "chartreuse3", "coral"), title = "WHO Region", cex = 0.75)


## ----C.1.2, out.width = "85%", echo = FALSE----------------------------
# Displaying figure 1 from paper.
knitr::include_graphics("paper_figure1.png")


## ----C.2.1-------------------------------------------------------------
# Calculating percentage deaths. 
region.deaths <- (c(
  "Africa" = sum(subset(country_wise$deaths, subset = country_wise$who.region == "Africa")),
  "Americas" = sum(subset(country_wise$deaths, subset = country_wise$who.region == "Americas")),
  "Eastern Mediterranean" = sum(subset(country_wise$deaths, subset = country_wise$who.region == "Eastern Mediterranean")),
  "Europe" = sum(subset(country_wise$deaths, subset = country_wise$who.region == "Europe")),
  "South-East Asia" = sum(subset(country_wise$deaths, subset = country_wise$who.region == "South-East Asia")),
  "Western Pacific" = sum(subset(country_wise$deaths, subset = country_wise$who.region == "Western Pacific"))))
region.deaths.pct <- region.deaths / sum(country_wise$deaths) * 100

# Generating plot. 
pct.deaths_bar <- barplot(region.deaths.pct, 
        main = "WHO Region (Updated Dataset)", 
        ylab = "Total Deaths %",
        col = c("goldenrod", "darkorchid2", "deeppink2", "darkturquoise", "chartreuse3", "coral"),
        cex.names = 0.59, 
        ylim = c(0, 65))
text(x = c(0.7, 1.9, 3.1, 4.3, 5.5, 6.7), y = region.deaths.pct + 4, labels = paste(as.character(round(region.deaths.pct, 2)), "%", sep = ""))
legend(x = "topright", legend = c("Africa", "Americas", "Eastern Mediterranean", "Europe", "South-East Asia", "Western Pacific"), fill = c("goldenrod", "darkorchid2", "deeppink2", "darkturquoise", "chartreuse3", "coral"), title = "WHO Region", cex = 0.75)


## ----C.2.2, out.width = "75%", echo = FALSE----------------------------
# Displaying figure 2 from paper. 
knitr::include_graphics("paper_figure2.png")


## ----C.3.1-------------------------------------------------------------
# Calculating metrics shown in graphs from paper. 
countries.confirmed <- c(
  "Brazil" = subset(country_wise$confirmed, subset = country_wise$country == "Brazil"), 
  "India" = subset(country_wise$confirmed, subset = country_wise$country == "India"),
  "Russia" = subset(country_wise$confirmed, subset = country_wise$country == "Russia"),
  "US" = subset(country_wise$confirmed, subset = country_wise$country == "US"))
countries.deaths <- c(
  "Brazil" = subset(country_wise$deaths, subset = country_wise$country == "Brazil"), 
  "India" = subset(country_wise$deaths, subset = country_wise$country == "India"),
  "Russia" = subset(country_wise$deaths, subset = country_wise$country == "Russia"),
  "US" = subset(country_wise$deaths, subset = country_wise$country == "US"))
countries.active <- c(
  "Brazil" = subset(country_wise$active, subset = country_wise$country == "Brazil"), 
  "India" = subset(country_wise$active, subset = country_wise$country == "India"),
  "Russia" = subset(country_wise$active, subset = country_wise$country == "Russia"),
  "US" = subset(country_wise$active, subset = country_wise$country == "US"))
countries.recovered <- c(
  "Brazil" = subset(country_wise$recovered, subset = country_wise$country == "Brazil"), 
  "India" = subset(country_wise$recovered, subset = country_wise$country == "India"),
  "Russia" = subset(country_wise$recovered, subset = country_wise$country == "Russia"),
  "US" = subset(country_wise$recovered, subset = country_wise$country == "US"))

# Converting to percentages.
countries.confirmed.pct <- countries.confirmed / sum(countries.confirmed) * 100
countries.deaths.pct <- countries.deaths / sum(countries.deaths) * 100
countries.active.pct <- countries.active / sum(countries.active) * 100
countries.recovered.pct <- countries.recovered / sum(countries.recovered) * 100

# Generating plots.
par(mfrow = c(2, 2))

barplot(countries.confirmed.pct, 
        main = "Countries", 
        ylab = "Total Confirmed %",
        col = c("purple", "pink", "lightblue", "turquoise"),
        ylim = c(0, 100))
text(x = c(0.8, 2.0, 3.2, 4.4), y = countries.confirmed.pct + 11, labels = paste(as.character(round(countries.confirmed.pct, 2)), "%", sep = ""))

barplot(countries.deaths.pct, 
        main = "Countries", 
        ylab = "Total Deaths %",
        col = c("purple", "pink", "lightblue", "turquoise"),
        ylim = c(0, 100))
text(x = c(0.8, 2.0, 3.2, 4.4), y = countries.deaths.pct + 11, labels = paste(as.character(round(countries.deaths.pct, 2)), "%", sep = ""))

barplot(countries.active.pct, 
        main = "Countries", 
        ylab = "Total Active %",
        col = c("purple", "pink", "lightblue", "turquoise"),
        ylim = c(0, 100))
text(x = c(0.8, 2.0, 3.2, 4.4), y = countries.active.pct + 11, labels = paste(as.character(round(countries.active.pct, 2)), "%", sep = ""))

barplot(countries.recovered.pct, 
        main = "Countries", 
        ylab = "Total recovered %",
        col = c("purple", "pink", "lightblue", "turquoise"),
        ylim = c(0, 100))
text(x = c(0.8, 2.0, 3.2, 4.4), y = countries.recovered.pct + 11, labels = paste(as.character(round(countries.recovered.pct, 2)), "%", sep = ""))


## ----c.3.2, echo = FALSE, out.width = "100%"---------------------------
# Displaying figure from paper. 
knitr::include_graphics("paper_figure3.png")


## ----D.1---------------------------------------------------------------
# Scaling the dataset.
country_wise.scaled <- country_wise
country_wise.scaled[, 2:14] <- scale(country_wise[, 2:14])
country_wise.scaled[, 15] <- country_wise[, 15]

# Ensuring column names are the same. 
colnames(country_wise.scaled) <- c("country", "confirmed", "deaths", "recovered", "active", "new.cases", "new.deaths", "new.recovered", "deaths100c", "recovered100c", "deaths100r", "confirmed.lastweek", "one.week.diff", "one.week.pct.inc", "who.region")


## ----D.2.1-------------------------------------------------------------
cor(country_wise.scaled[, 2:14])


## ----D.2.2-------------------------------------------------------------
# Creating a pairs plot for the dataset. 
pairs(country_wise.scaled[2:14])


## ----D.3.1-------------------------------------------------------------
# Running PCA on scaled data. 
country_wise.pca <- prcomp(country_wise[2:14], scale = TRUE)

# Displaying scree plot. 
fviz_screeplot(country_wise.pca)
summary(country_wise.pca)


## ----D.3.2, out.width = "100%"-----------------------------------------
# Showing scree plot from paper. 
knitr::include_graphics("paper_figure4.png")


## ----D.4.1-------------------------------------------------------------
# Displaying the loadings from the first three data points in the PCA. 
country_wise.pca$rotation[, 1:3]


## ----D.4.2-------------------------------------------------------------
# Displaying the loadings as vectors in 2-dimensional PCA plot. 
fviz_pca_var(country_wise.pca,
             col.var = "contrib", # Color by contributions to the PC
                                 gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                                 repel = TRUE)


## ----D.4.3-------------------------------------------------------------
# Showing individual contributions (scores) from the PCA. 
fviz_pca_ind(country_wise.pca,
             col.ind = "cos2", # Color by the quality of representation
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
             )


## ----D.4.4-------------------------------------------------------------
# Displaying outlier data points. 
country_wise.scaled[c(174, 121, 178), ]$country


## ----D.4.5-------------------------------------------------------------
# Removing USA from the dataset. 
country_wise.scaled.noUS <- country_wise.scaled[-174, ]

# Running PCA. 
country_wise.pca.noUS <- prcomp(country_wise.scaled.noUS[, 2:14], scale = FALSE)

# Displaying loadings as vectors. 
fviz_pca_var(country_wise.pca.noUS,
             col.var = "contrib", # Color by contributions to the PC
                                 gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                                 repel = TRUE)

# Displaying individuals plot. 
fviz_pca_ind(country_wise.pca.noUS,
             col.var = "contrib", # Color by contributions to the PC
             col.ind = "cos2", 
                                 gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                                 repel = TRUE)


## ----E.1.1-------------------------------------------------------------
# Viewing elbow plot of K-means clustering without PCA.
fviz_nbclust(country_wise.scaled[2:14], kmeans, method = 'wss')

# Viewing elbow plot of K-means clustering with PCA. 
fviz_nbclust(country_wise.pca$x, kmeans, method = "wss")


## ----E.1.2, echo = FALSE, out.width = "100%"---------------------------
# Viewing elbow plot from paper. 
knitr::include_graphics("paper_figure5.png")


## ----E.1.3-------------------------------------------------------------
# Viewing elbow plot based on silhouette width without PCA. 
fviz_nbclust(country_wise.scaled[2:14], kmeans, method = 'silhouette')

# Viewing elbow plot based on silhouette width with PCA. 
fviz_nbclust(country_wise.pca$x, kmeans, method = "silhouette")


## ----E.2.1-------------------------------------------------------------
# Adding country codes. 
country_wise.scaled$code <- countrycode(country_wise.scaled$country, origin = "country.name", destination = "iso3c")

# Manually adding code for Kosovo. 
country_wise.scaled[92, ]$code <- "XK"


## ----E.2.2-------------------------------------------------------------
# Performing clusterings K = 6
  # With PCA
  kmeans6_country.pca <- kmeans(country_wise.pca$x[, 1:8], centers = 6)  
  country_wise.scaled$clusters6.pca <- kmeans6_country.pca$cluster

  # Without PCA
  kmeans6_country.nopca <- kmeans(country_wise.scaled[, 2:14], centers = 6)
  country_wise.scaled$clusters6.nopca <- kmeans6_country.nopca$cluster
  
# Performing clusterings K = 7
  # With PCA
  kmeans7_country.pca <- kmeans(country_wise.pca$x[, 1:8], centers = 7)  
  country_wise.scaled$clusters7.pca <- kmeans7_country.pca$cluster

  # Without PCA
  kmeans7_country.nopca <- kmeans(country_wise.scaled[, 2:14], centers = 7)
  country_wise.scaled$clusters7.nopca <- kmeans7_country.nopca$cluster
  
# Performing clusterings K = 2
  # With PCA
  kmeans2_country.pca <- kmeans(country_wise.pca$x[, 1:8], centers = 2)  
  country_wise.scaled$clusters2.pca <- kmeans2_country.pca$cluster

  # Without PCA
  kmeans2_country.nopca <- kmeans(country_wise.scaled[, 2:14], centers = 2)
  country_wise.scaled$clusters2.nopca <- kmeans2_country.nopca$cluster


## ----E.2.3, warning = FALSE, message = FALSE---------------------------
# Generating map for clustering with PCA.  
k6clusters.PCA <- data.frame(country = country_wise.scaled$code, cluster6pca = country_wise.scaled$clusters6.pca)
k6Map.PCA <- joinCountryData2Map(k6clusters.PCA, joinCode = "ISO3", nameJoinColumn = "country")
mapCountryData(k6Map.PCA, nameColumnToPlot = "cluster6pca", catMethod = "categorical", missingCountryCol = gray(0.8), colourPalette = c("lightblue", "lightpink", "purple", "tan", "forestgreen", "darkblue"))

# Generating map for clustering without PCA. 
k6clusters.noPCA <- data.frame(country = country_wise.scaled$code, cluster6nopca = country_wise.scaled$clusters6.nopca)
k6Map.noPCA <- joinCountryData2Map(k6clusters.noPCA, joinCode = "ISO3", nameJoinColumn = "country")
mapCountryData(k6Map.noPCA, nameColumnToPlot = "cluster6nopca", catMethod = "categorical", missingCountryCol = gray(0.8), colourPalette = c("purple", "lightblue", "darkblue", "forestgreen", "tan", "lightpink"))


## ----E.2.4, out.width = "100%"-----------------------------------------
# Figure K = 6, PCA applied
knitr::include_graphics("paper_figure6.png")

# Figure K = 6, no PCA applied
knitr::include_graphics("paper_figure7.png")


## ----E.2.5, echo = FALSE, out.width = "100%"---------------------------
knitr::include_graphics("paper_figure8.png")


## ----E.2.6-------------------------------------------------------------
table(country_wise.scaled$clusters6.pca, country_wise.scaled$who.region)


## ----E.2.7, warning = FALSE, message = FALSE---------------------------
# Generating map for clustering with PCA.  
k7clusters.PCA <- data.frame(country = country_wise.scaled$code, cluster7pca = country_wise.scaled$clusters7.pca)
k7Map.PCA <- joinCountryData2Map(k7clusters.PCA, joinCode = "ISO3", nameJoinColumn = "country")
mapCountryData(k7Map.PCA, nameColumnToPlot = "cluster7pca", catMethod = "categorical", missingCountryCol = gray(0.8), colourPalette = c("lightblue", "lightpink", "purple", "tan", "forestgreen", "darkblue", "brown"))

# Generating map for clustering without PCA. 
k7clusters.noPCA <- data.frame(country = country_wise.scaled$code, cluster7nopca = country_wise.scaled$clusters7.nopca)
k7Map.noPCA <- joinCountryData2Map(k7clusters.noPCA, joinCode = "ISO3", nameJoinColumn = "country")
mapCountryData(k7Map.noPCA, nameColumnToPlot = "cluster7nopca", catMethod = "categorical", missingCountryCol = gray(0.8), colourPalette = c("purple", "darkblue", 
"lightpink", "forestgreen", "tan", "lightblue", "brown"))


## ----E.2.8, out.width = "100%"-----------------------------------------
# Figure K = 7, PCA applied.
knitr::include_graphics("paper_figure9.png")

# Figure K = 7, no PCA applied. 
knitr::include_graphics("paper_figure10.png")


## ----E.2.9, echo = FALSE, out.width = "100%"---------------------------
knitr::include_graphics("paper_figure11.png")


## ----E.2.10------------------------------------------------------------
table(country_wise.scaled$clusters7.pca, country_wise.scaled$who.region)


## ----E.2.11, warning = FALSE, message = FALSE--------------------------
# Generating map for clustering with PCA.  
k2clusters.PCA <- data.frame(country = country_wise.scaled$code, cluster2pca = country_wise.scaled$clusters2.pca)
k2Map.PCA <- joinCountryData2Map(k2clusters.PCA, joinCode = "ISO3", nameJoinColumn = "country")
mapCountryData(k2Map.PCA, nameColumnToPlot = "cluster2pca", catMethod = "categorical", missingCountryCol = gray(0.8), colourPalette = c("red", "blue"))

# Generating map for clustering without PCA. 
k2clusters.noPCA <- data.frame(country = country_wise.scaled$code, cluster2nopca = country_wise.scaled$clusters2.nopca)
k2Map.noPCA <- joinCountryData2Map(k2clusters.noPCA, joinCode = "ISO3", nameJoinColumn = "country")
mapCountryData(k2Map.noPCA, nameColumnToPlot = "cluster2nopca", catMethod = "categorical", missingCountryCol = gray(0.8), colourPalette = c("blue", "red"))

