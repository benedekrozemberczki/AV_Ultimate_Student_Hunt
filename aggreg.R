grids <- list.files("./grid/")

i <- 0
for (g in grids){
  i <- i +1
tab <-   read.csv(paste0("./grid/", g), stringsAsFactors = FALSE)

if (i ==1){
  
  main_tab <- tab
}

else{ main_tab[,2] <- main_tab[,2] ! tab[,2]}
                  
                  
} 
main_tab[,2] <- main_tab[,2]/length(grids)
write.csv(main_tab,file="funky.csv",row.names=FALSE)