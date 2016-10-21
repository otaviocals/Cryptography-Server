receive_r_object <- function(received_data,envir=parent.frame())
	{
		file.create("rec_data")
		file_con <- file("rec_data","wb")
		writeLines(received_data,file_con)
		close(file_con)
		file.create("rec_data2")
		file_con2 <- file("rec_data2","wb")
		write.table(readLines("rec_data"),file=file_con2,row.names=FALSE,col.names=FALSE,quote=FALSE,eol="\n")
		close(file_con2)
		load("rec_data",envir=envir)
		unlink("rec_data")
		unlink("rec_data2")
	}