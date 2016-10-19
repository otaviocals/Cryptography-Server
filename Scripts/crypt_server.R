crypt_server <- function(host_address = "localhost")
	{

#Loading Scripts

		source("Scripts/pkgTest.R")
		source("Scripts/server_user_data_parser.R")

		while(TRUE)
			{
				writeLines("Listening...")
				con <- socketConnection(host=host_address, port = 32323, blocking=TRUE,server=TRUE, open="r+")
				data <- readLines(con, 1)
				print(data)
				user_info_frame <- server_user_data_parser(data)
				print(user_info_frame)
				response <- toupper(data) 
				writeLines(response, con) 
				close(con)
			}
	}