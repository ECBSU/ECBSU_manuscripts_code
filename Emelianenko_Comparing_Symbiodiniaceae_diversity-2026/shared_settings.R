Symbiodiniaceae_color_palette = c(
  "Symbiodinium"=      "#F8333C",
  "Cladocopium" =      "#FFEE7F",
  "Durusdinium" =      "#7AC74F",
  "Fugacium" =         "#57B8FF",
  "Freudenthalidium" = "#2176AE",
  "Miliolidium" =      "#68EDC6",
  "clade_I"  =         "#00423d", 
  "clade_J" =          "#FAFCF0",
  "Halluxium" =        "#FF10F0",
  "clade_Fr4" =        "#ADF802"
  )



samples_color_palette <- c(   
  "Goniastrea"   =  "#fdd85d",   
  "Porites" =       "#fdd85d",  
  "Montipora"    =  "#fdd85d",  
  "Stichodactyla"=  "#fdd85d",    
  "Tridacna"     =  "#bf211e",  
  "Sediment"     =  "#510D0A",  
  "Algae"        =  "#77B400",  
  "Water"        =  "#1e88e5",         
  "Amphisorus" =    "#731DD8",  
  "Sorites"    =    "#C9AEFF"   
  )


host_tax_color_palette <- c(
  "Anthozoa"   =   "#fdd85d", 
  "Tridacna"     = "#bf211e",  
  "Sediment"     = "#510D0A",  
  "Algae"        = "#77B400",  
  "Water"        = "#1e88e5",         
  "Amphisorus" =   "#731DD8",  
  "Sorites"    =   "#C9AEFF"   
  )

# Not needed unless PCoA is run separately with/without Tridacna
tridacna_color_palette = c(
  "Anthozoa"   =   "#3b3b3b", 
  "Amphisorus"   = "#3b3b3b",  
  "Sorites"      = "#3b3b3b",  
  "Sediment"     = "#3b3b3b",  
  "Algae"        = "#3b3b3b",  
  "Water"        = "#3b3b3b",  
  "Tridacna"     = "#bf211e"   
  )


clades_color_palette = c(
  "clade A"=   "#F8333C",
  "clade C" =  "#FFEE7F",
  "clade D" =  "#7AC74F",
  "clade F" =  "#2176AE",
  "clade I"  = "#00423d",
  "clade H" =  "#FF10F0", 
  "clade B" =  "#592E83"
  )

dinoflagellates_order_palette <- c("Symbiodiniaceae" =       '#ffffe5', 
                                   "Suessiales spp." =       '#afe1e4',
                                   "Gymnodiniales" =         '#6e979f',
                                   'Dinoflagellates NA'=     '#7072ac',
                                   "Peridiniales" =          '#4c007f',
                                   "Dinoflagellates other" = '#2d0035'
                                   )

host_tax_order <- c(
  "Tridacna",
  "Anthozoa" , 
  "Amphisorus" ,  
  "Sorites" , 
  "Algae" ,
  "Sediment",  
  "Water"
  )

type_order = c(
  "Tridacna",
  "Goniastrea", 
  "Porites", 
  "Montipora",
  "Stichodactyla", 
  "Amphisorus", 
  "Sorites", 
  "Algae", 
  "Sediment", 
  "Water"
  )

host_type_order = c(
  "Multicellular hosts",
  "Foraminifera", 
  "Environment"
  )

type_labels = c(
  "Tridacna" = expression(italic("Tridacna")), 
  "Porites" = expression(italic("Porites")),
  "Montipora" = expression(italic("Montipora")),
  "Goniastrea" = expression(italic("Goniastrea")),
  "Stichodactyla" = expression(italic("Stichodactyla")), 
  "Amphisorus" = expression(italic("Amphisorus")), 
  "Sorites" = expression(italic("Sorites")), 
  "Algae" = "Algae (bulk)", 
  "Sediment" = "Sediment (bulk)", 
  "Water" = "Water"
)

Symbiodiniaceae_clade_order = c(
  "clade A",  # Symbiodinium
  "clade B",  # Breviolum
  "clade C",  # Cladocopium
  "clade D",  # Durusdinium
  "clade F",  # Freudenthalidium (F3 /Fr3) and Fugacium (F5 / Fr5)
  "clade H",  # Halluxium
  "clade I"  # clade I - no genus name
)

Symbiodiniaceae_genera_order = c(
  "Symbiodinium",
  "Cladocopium",
  "Durusdinium",
  "Freudenthalidium",
  "Fugacium",
  "Miliolidium",
  "clade_J",
  "clade_I", 
  "Halluxium",
  "clade_Fr4"
  )

Symbiodiniaceae_genera_labels <- c(
  "Symbiodinium"    = expression(italic("Symbiodinium")),
  "Cladocopium"     = expression(italic("Cladocopium")),
  "Durusdinium"     = expression(italic("Durusdinium")),
  "Freudenthalidium"= expression(italic("Freudenthalidium")),
  "Fugacium"        = expression(italic("Fugacium")),
  "Miliolidium"     = expression(italic("Miliolidium")),
  "Halluxium"       = expression(italic("Halluxium")),
  "clade_I"         = "clade_I",
  "clade_J"         = "clade_J",
  "clade_Fr4" = "clade_Fr4"
)


Symbiodiniaceae_sample_order = c(
  # Tridacna
  "Tridacna7", "Tridacna1", "Tridacna8",   "Tridacna6", "Tridacna2", "Tridacna3", "Tridacna4", "Tridacna5", "Tridacna9", 
  
  # Goniastrea
  "Goniastrea1-3",
  "Goniastrea1-1",  "Goniastrea1-5",  "Goniastrea1-9","Goniastrea1-14",
  "Goniastrea2-2", "Goniastrea2-14","Goniastrea2-18","Goniastrea2-16","Goniastrea2-19",
  
  # POrites
  "Porites1-6",                                                 
  "Porites2-3", "Porites2-1", "Porites2-7", "Porites2-9","Porites1-12", 
  
  # Montipora
  "Montipora1-2", "Montipora2-6", 
  
  # Anemone
  "Stichodactyla1-1", "Stichodactyla1-2", 
  
  # Amphisorus
  "Amphisorus1-7", "Amphisorus1-2", "Amphisorus2-6",  "Amphisorus2-1",   "Amphisorus2-3",  "Amphisorus1-3",
  "Amphisorus1-4", "Amphisorus1-5",   "Amphisorus1-10", "Amphisorus2-5", 
  "Amphisorus2-2", "Amphisorus2-4", "Amphisorus2-30", "Amphisorus2-31", 
  
  # Sorites
  "Sorites1-12",  "Sorites1-14", "Sorites1-9",  
  "Sorites2-22", "Sorites2-29", "Sorites2-21", "Sorites1-13",
  
  # Algae
  "Algae2-2", "Algae2-6","Algae1-2","Algae1-5","Algae1-1",
  "Algae2-7", "Algae2-5", "Algae1-6", 
  
  # Sediment
  "Sediment1-5", "Sediment2-5","Sediment2-6", "Sediment1-7", "Sediment1-8", "Sediment2-4",   "Sediment2-9",
  "Sediment1-6",
  
  # Water
  "Water1-2","Water1-4", "Water1-1", "Water1-3", 
  "Water2-7","Water2-6","Water2-5", "Water2-8"
  )


my_theme <- theme_minimal(base_family = "Arial") # set the same fonts for all plots
theme_set(my_theme)

# To check fonts available 
# library(systemfonts)
# system_fonts() 

# Remove text constraints from svg so that it will be plain text in InkScape
clean_svg <- function(infile, outfile = infile) {
  txt <- readLines(infile, warn = FALSE)
  txt <- gsub("textLength='[^']*' ?", "", txt)
  txt <- gsub("lengthAdjust='[^']*' ?", "", txt)
  writeLines(txt, outfile)
}

# Write svg and then clean up text file 
ggsave_clean <- function(filename, plot = last_plot(), ..., device = NULL) {
  ggsave(filename, plot = plot, device = device, ...)
  if (grepl("\\.svg$", filename, ignore.case = TRUE)) {
    clean_svg(filename)
  }
}

