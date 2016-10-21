send_r_object <- function(object)
	{
		object_name <- deparse(substitute(object))
		file_name <- paste0(object_name,".Rdata")
		assign(object_name,object)
		save(list = object_name,file=file_name,ascii=TRUE,compress=FALSE)
		data <- readLines(file_name)
		unlink(file_name)
		data
	}