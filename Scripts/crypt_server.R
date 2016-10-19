crypt_server <- function(host_address = "localhost")
	{

#Loading Scripts

		source("Scripts/pkgTest.R")
		source("Scripts/server_user_data_parser.R")
		source("Scripts/vrfy_usr.R")

#Loading Data

		user_data <- read.csv("Data/user_data.csv")

#Server

		while(TRUE)
			{
				writeLines("Listening...")
				con <- socketConnection(host=host_address, port = 32323, blocking=TRUE,server=TRUE, open="r+")
				data <- readLines(con, 1)
				user_info_frame <- server_user_data_parser(data)
				response <- toString(vrfy_usr(user_info_frame,user_data))
				writeLines(response, con) 
				close(con)
			}
	}