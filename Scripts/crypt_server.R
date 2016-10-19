crypt_server <- function(host_address = "localhost")
	{
		while(TRUE)
			{
				writeLines("Listening...")
				con <- socketConnection(host=host_address, port = 32323, blocking=TRUE,server=TRUE, open="r+")
				data <- readLines(con, 1)
				print(data)
				response <- toupper(data) 
				writeLines(response, con) 
				close(con)
			}
	}