crypt_server <- function(host_address = "localhost")
	{

#Loading Scripts

		source("Scripts/pkgTest.R")
		source("Scripts/server_user_data_parser.R")
		source("Scripts/vrfy_usr.R")

#Loading Data

		user_data_table <- read.csv("Data/user_data.csv")

#Server

		while(TRUE)
			{
				writeLines("Listening...")
				con <- socketConnection(host=host_address, port = 32323, blocking=TRUE,server=TRUE, open="r+")
				data <- readLines(con, 1)
				user_info_frame <- server_user_data_parser(data)
				response <- toString(vrfy_usr(user_info_frame,database = user_data_table))
				writeLines(response, con) 
#Auth Successful
				if(response==0)
				{
					writeLines("Listening to Action...")

					while(TRUE)
					{
						action <- readLines(con, 1)
						writeLines(action)
#Listing Data
						if(action=="1")
						{
							writeLines("Reading User Workspace...")
						}
#Reading Data
						else if(action=="2")
						{
							writeLines("Reading Data...")
						}
#Writing Data
						else if(action=="3")
						{
							writeLines("Writing Data...")
						}
#Deleting Data
						else if(action=="4")
						{
							writeLines("Deleting Data...")
						}
#Account Summary
						else if(action=="5")
						{
							writeLines("Sending Summary...")
						}
#Logout
						else if(action=="6")
						{
							break
						}
#Invalid Action
						else
						{
							writeLines("Invalid Action.")
						}
					}
				}

				close(con)
			}
	}