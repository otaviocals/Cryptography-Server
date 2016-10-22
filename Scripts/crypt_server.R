crypt_server <- function(host_address = "localhost")
	{

		user_data_limit <- 104857600


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
								writeLines("0",con)
							}
							else
							{
								writeLines("1",con)
								text_data_to_send <- send_r_object(read_file)
								data_length <- length(text_data_to_send)
								data_length_string <- toString(data_length)
								data_length_send <- writeLines(data_length_string,con)
								for(i in 1:data_length)
								{
									current_line <- writeLines(text_data_to_send[i],con)
								}
							}

							rm(read_file)
						}
#Writing Data
						else if(action=="3")
						{
							envir_size <- object.size(get0(ls(envir=user_envir),envir=user_envir))

							writeLines("Writing Data...")
							file_to_write_size <- readLines(con, 1)
							file_to_write <- readLines(con, 1)
							total_size <- envir_size+strtoi(file_to_write_size)
							writeLines(file_to_write)

							if(nchar(file_to_write)>0 && total_size < user_data_limit)
							{

								exceed <- writeLines("1",con)

								if(exists(file_to_write,envir=user_envir))
								{
									file_exists_server <- writeLines("1",con)
									overwrite_response <- readLines(con, 1)
									if(overwrite_response=="y")
									{
										data_length <- readLines(con, 1)
										data_length_int <- strtoi(data_length)
										for(i in 1:data_length_int)
										{
											current_line <- readLines(con, 1)
											if(exists("received_text_data"))
											{
												received_text_data <- c(received_text_data,current_line)
											}
											else
											{
												received_text_data <- current_line
											}
										}
										receive_r_object(received_text_data,envir=user_envir)
										assign(file_to_write,get0("file_to_write_object",envir=user_envir),envir=user_envir)
										rm("file_to_write_object",envir=user_envir)
										rm(list=c("total_size","file_to_write_size","envir_size","current_line","data_length","data_length_int","file_exists_server","file_to_write","i","received_text_data"))
										save(list=ls(envir=user_envir),file=user_stored_data_address,envir=user_envir)
									}
								}
								else
								{
									file_exists_server <- writeLines("0",con)
									data_length <- readLines(con, 1)
									data_length_int <- strtoi(data_length)
									for(i in 1:data_length_int)
									{
										current_line <- readLines(con, 1)
										if(exists("received_text_data"))
										{
											received_text_data <- c(received_text_data,current_line)
										}
										else
										{
											received_text_data <- current_line
										}
									}
									receive_r_object(received_text_data,envir=user_envir)
									assign(file_to_write,get0("file_to_write_object",envir=user_envir),envir=user_envir)
									rm("file_to_write_object",envir=user_envir)
									rm(list=c("total_size","file_to_write_size","envir_size","current_line","data_length","data_length_int","file_exists_server","file_to_write","i","received_text_data"))
									save(list=ls(envir=user_envir),file=user_stored_data_address,envir=user_envir)
								}
							}
							else if (nchar(file_to_write)>0 && total_size > user_data_limit)
							{
								exceed <- writeLines("0",con)
							}
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