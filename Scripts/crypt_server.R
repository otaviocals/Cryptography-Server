crypt_server <- function(host_address = "localhost")
	{

#Loading Scripts

		source("Scripts/pkgTest.R")
		source("Scripts/server_user_data_parser.R")
		source("Scripts/vrfy_usr.R")
		source("Scripts/receive_r_object.R")
		source("Scripts/send_r_object.R")

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
#Load User Environment
					user_name<-toString(user_info_frame[1,1])
					user_stored_data_address <- paste0("Data/usr_data/",user_name,".RData")
					if(file.exists(user_stored_data_address))
					{
						writeLines("Loading Environment...")
						user_envir <- new.env()
						load(user_stored_data_address,envir=user_envir)
					}
					else
					{
						writeLines("Creating Environment...")
						suppressWarnings(save(file=user_stored_data_address))
						writeLines("Loading Environment...")
						user_envir <- new.env()
						load(user_stored_data_address,envir=user_envir)
					}


					while(TRUE)
					{

						writeLines("Listening to Action...")

						action <- readLines(con, 1)
						writeLines(action)
#Listing Data
						if(action=="1")
						{
							writeLines("Reading User Workspace...")
							envir_data_list <- toString(ls(envir=user_envir))
							if(nchar(envir_data_list)==0)
							{
								envir_data_list <- "NO DATA"
							}
							writeLines(envir_data_list,con)
							rm(envir_data_list)
						}
#Reading Data
						else if(action=="2")
						{
							writeLines("Reading Data...")
							file_to_read <- readLines(con, 1)
							if(nchar(file_to_read)>0)
							{
								read_file <- get0(file_to_read,envir=user_envir)
							}
							else
							{
								read_file <- NULL
							}
							if(is.null(read_file))
							{
								read_response <- "Object not found."
							}
							else
							{
								read_response <- toString(print(read_file))
							}
							writeLines(read_response,con)
							rm(read_response)
							rm(read_file)
						}
#Writing Data
						else if(action=="3")
						{
							writeLines("Writing Data...")
							file_to_write <- readLines(con, 1)
							print(file_to_write)
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
							writeLines("Unloading User Data...")
							rm(user_envir)
							writeLines("Logging Out")
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