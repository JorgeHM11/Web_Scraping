
# Cargar librerías --------------------------------------------------------
library(rvest)      # HTML Hacking & Web Scraping
library(tidyverse)  # Data Manipulation
library(openxlsx)   # Excel manipulation
library(xopen)      # Opens URL in Browser
library(beepr)      # Notification sounds

# Guardar URL -------------------------------------------------------------
url <- "http://repositorio.unfv.edu.pe/handle/UNFV/1445/recent-submissions"
xopen(url)

# Leer HTML ---------------------------------------------------------------
page <- read_html(url)

# Extraer Escuela Profesional 
get_epp <- function(x) {
  tesis_page <- read_html(x)
  tesis_epp  <- tesis_page %>% html_nodes(".ds-referenceSet-list a") %>%
    html_text()
  return(tesis_epp)
}

# Extraer Tópicos
get_subject  <- function(x) {
  tesis_page <- read_html(x)
  tesis_subject  <- tesis_page %>% html_nodes(".odd:nth-child(17) .word-break , .even:nth-child(16) .word-break , .odd:nth-child(15) .word-break") %>%
    html_text() %>% paste(collapse = ",")
  return(tesis_subject)
}

# Extraer Asesor
get_asesor  <- function(x) {
  tesis_page <- read_html(x)
  tesis_asesor  <- tesis_page %>% html_nodes(".odd:nth-child(1) .word-break") %>%
    html_text() 
  return(tesis_asesor)
}


df <- data.frame()

#Loop para 3 páginas
for (page_result in seq(from = 0, to = 40, by = 20)) {
  link <- paste("http://repositorio.unfv.edu.pe/handle/UNFV/1445/recent-submissions",
                "?offset=", page_result, sep = "")
  page <- read_html(link)
  
  acceso <- page %>% html_nodes(".label") %>% html_text()
  año    <- page %>% html_nodes(".date") %>% html_text()
  titulo <- page %>% html_nodes("#aspect_discovery_recentSubmissions_RecentSubmissionTransformer_div_recent-submissions a") %>% html_text()
  autor  <- page %>% html_nodes(".author span") %>% html_text()
  univ   <- page %>% html_nodes(".publisher") %>% html_text()
  abstract   <- page %>% html_nodes(".artifact-abstract") %>% html_text()
  tesis_links <- page %>% html_nodes("#aspect_discovery_recentSubmissions_RecentSubmissionTransformer_div_recent-submissions a") %>% 
    html_attr("href") %>% paste("http://repositorio.unfv.edu.pe", ., sep = "")
  tesis_links_full <- page %>% html_nodes("#aspect_discovery_recentSubmissions_RecentSubmissionTransformer_div_recent-submissions a") %>% 
    html_attr("href") %>% paste("http://repositorio.unfv.edu.pe", .,"?show=full", sep = "") 
  epp <- sapply(tesis_links, FUN = get_epp, USE.NAMES = FALSE)
  subject <- sapply(tesis_links_full, FUN = get_subject, USE.NAMES = FALSE) 
  asesor  <- sapply(tesis_links_full, FUN = get_asesor, USE.NAMES = FALSE)
  
  df <- rbind(df, data.frame(tesis_links, titulo, autor,asesor, acceso, univ, año, abstract, epp, subject)) 
  
  print(paste("Page:",page_result))
  
}

beep(8) # Notificar compilado exitoso

view(df)

# Exportar data como archivo excel ----
write.xlsx(df, "prueba.xlsx")








