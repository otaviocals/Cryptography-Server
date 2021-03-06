crypt_client <- function(host_address = "localhost")
	{

#Loading Scripts

		source("Scripts/pkgTest.R")
		source("Scripts/submit_usr.R")
		source("Scripts/receive_r_object.R")
		source("Scripts/send_r_object.R")

#Loading Packages

		packages_to_load <- c("sodium","getPass")

		for(i in 1:length(packages_to_load))
		{
			pkg_loaded <- suppressWarnings(pkgTest(packages_to_load[i]))
			if(!pkg_loaded)
			{
				print("Could not install a necessary R package. Please verify your internet connection.")
				pkgs <- FALSE
				break
			}
			else
			{
				pkgs <- TRUE
			}
		}

#Connecting to Server

		stop_con <- FALSE

		while(pkgs)
			{
				con <- socketConnection(host=host_address, port = 32323, blocking=TRUE,server=FALSE, open="r+")
				f <- file("stdin")
				open(f)


				cat("\nAuthentication, press q to quit\n")
				cat("\nUsername:\n")
				user <- readLines(f, n=1)
				if(tolower(user)=="q")
				{
					cat("\nExiting Server.\n\n")
					closeAllConnections()
					break
				}
				pass <- getPass(msg="\nPassword:\n")

				if(tolower(pass)=="q")
				{
					cat("\nExiting Server.\n\n")
					closeAllConnections()
					break
				}

				user_info <- submit_usr(user,pass)
				write_resp <- writeLines(user_info, con)


				server_resp <- readLines(con, 1)

#Auth Successful
				if(strtoi(server_resp) > 0)
				{
					cat("\nAuthenticated!\n\n")
					
					writeLines(toString(Sys.info()["sysname"]), con)

					while(TRUE)
					{
						cat("\nChoose an action:\n 1 - List Data          2 - Read Data          3 - Write Data\n 4 - Delete Data        5 - Account Summary    6 - Logout\n")
						action <- readLines(f, n=1)
						write_action <- writeLines(action, con)
#Listing Data
						if(action=="1")
						{
							cat("\nCurrent Data:\n")
							envir_data_list <- readLines(con, 1)
							cat("\n",envir_data_list,"\n")
							rm(envir_data_list)
						}
#Reading Data
						else if(action=="2")
						{
							cat("\nEnter Object Name.\n")
							file_to_read <- readLines(f, n=1)
							write_read_file <- writeLines(file_to_read,con)
							read_data <- readLines(con,1)
							if(read_data=="0")
							{
								cat("\nObject not Found.\n")
								rm(read_data)
								rm(file_to_read)
							}
							else if(read_data=="1")
							{
								data_length_string <- readLines(con,1)
								data_length_int <- strtoi(data_length_string)
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
								receive_r_object(received_text_data)
								
								cat("\nLoad Object into Workspace? [y/n]\n")
								load_to_work <- readLines(f, n=1)
								if(tolower(load_to_work)=="y")
								{
									if(!exists(file_to_read,envir=.GlobalEnv))
									{
										cat("\nFile loaded into Workspace.\nReading Data...\n\n")
										assign(file_to_read,read_file,envir=.GlobalEnv)
										print(read_file)
									}
									else
									{
										cat("\nSame name file detected in Workspace. Overwrite it? [y/n]\n")
										overwrite_local <- readLines(f, n=1)
										if(tolower(overwrite_local)=="y")
										{
											cat("\nFile loaded into Workspace.\nReading Data...\n\n")
											assign(file_to_read,read_file,envir=.GlobalEnv)
											print(read_file)
										}
										else if(tolower(overwrite_local)=="n")
										{
											cat("\nFile not loaded into Workspace.\nReading Data...\n\n")
											print(read_file)
										}
										else
										{
											cat("\nWrong Input. File not loaded into Workspace.\nReading Data...\n\n")
											print(read_file)
										}
									}
								}
								else if(tolower(load_to_work)=="n")
								{
									cat("\nReading Data...\n\n")
									print(read_file)
								}
								else
								{
									cat("\nWrong Input. File not loaded into Workspace.\nReading Data...\n\n")
									print(read_file)
								}
								rm("current_line","data_length_int","data_length_string","file_to_read","i","load_to_work","read_data","received_text_data","read_file")
								
							}

						}
#Writing Data
						else if(action=="3")
						{
							cat("\nEnter Object Name.\n")
							file_to_write <- readLines(f, n=1)
							file_to_write_object <- get0(file_to_write)
							if(is.null(file_to_write_object))
							{
								cat("\nObject not found.\n")
								write_read_file_size <- writeLines("0",con)
								write_read_file <- writeLines("",con)

							}
							else
							{
								file_size <- toString(object.size(file_to_write_object))
								write_read_file_size <- writeLines(file_size,con)
								write_read_file <- writeLines(file_to_write,con)
								exceed <- readLines(con, n=1)
								if(exceed=="1")
								{
									exists_data <- readLines(con, n=1)
									if(exists_data=="1")
									{
										cat("\nSame name file found on server. Overwrite? [y/n]\n")
										overwrite <- readLines(f, n=1)
										if(tolower(overwrite)=="y")
										{
											overwrite_response <- writeLines(tolower(overwrite),con)
											cat("\nOverwriting File...\n")
											write_object_text_data <- send_r_object(file_to_write_object)
											data_length <- length(write_object_text_data)
											data_length_string <- toString(data_length)
											data_length_send <- writeLines(data_length_string,con)
											for(i in 1:data_length)
											{
												current_line <- writeLines(write_object_text_data[i],con)
											}
										}
										else if(tolower(overwrite)=="n")
										{
											overwrite_response <- writeLines(tolower(overwrite),con)
											cat("\nFile not Overwritten.\n")
										}
										else
										{
											overwrite_response <- writeLines(tolower(overwrite),con)
											cat("\nInocrrect input. File not Overwritten.\n")
										}
									}
									else if(exists_data=="0")
									{
										cat("\nWriting File...\n")
										write_object_text_data <- send_r_object(file_to_write_object)
										data_length <- length(write_object_text_data)
										data_length_string <- toString(data_length)
										data_length_send <- writeLines(data_length_string,con)
										for(i in 1:data_length)
										{
											current_line <- writeLines(write_object_text_data[i],con)
										}
									}
								}
								else
								{
									cat("\nFile Exceeds Data Limit\n")
								}
							}

						}
#Deleting Data
						else if(action=="4")
						{
							cat("\nEnter Object Name.\n")
							file_to_delete <- readLines(f, n=1)
							delete_file <- writeLines(file_to_delete,con)
							delete_data <- readLines(con,1)
							if(delete_data=="0")
							{
								cat("\nData not Found.\n")
							}
							else
							{
								cat("\nConfirm Data Deletion? [y/n]\n")
								delete_confirm <- readLines(f, n=1)
								if(tolower(delete_confirm)=="y")
								{
									writeLines("1",con)
									cat("\nData Deleted.\n")
								}
								else if(tolower(delete_confirm)=="n")
								{
									writeLines("0",con)
									cat("\nData not Deleted.\n")
								}
								else
								{
									writeLines("0",con)
									cat("\nInvalid Input. Data not Deleted.\n")
								}
								rm(delete_confirm)
							}
							rm(delete_data)
							rm(file_to_delete)
							
						}
#Account Summary
						else if(action=="5")
						{
							previous_date <- readLines(con, 1)
							previous_os <- readLines(con, 1)
							init_date <- readLines(con, 1)
							envir_size <- readLines(con, 1)
							user_data_limit <- readLines(con, 1)
							cat("\nAccount Summary:\n")
							cat("\nTotal Memory Allocated: ",envir_size,"/",user_data_limit,"\nRegistration Date: ",init_date,"\nLast Login: ",previous_date,"\nLast OS: ",previous_os,"\n")
							rm(list=c("previous_date","previous_os","init_date","envir_size","user_data_limit"))
						}
#Logout
						else if(action=="6")
						{
							cat("\nLogging Out...\n")
							break
						}
#Invalid Action
						else
						{
							cat("\nInvalid Action.\n")
						}
					}
				}
#Failure to Auth
				else if(strtoi(server_resp) == 0)
				{
					cat("\nUser or Password is wrong.\n\n")
					close(con)
					break
				}
#Server Error
				else
				{
					cat("\nServer Error\n\n")
					close(con)
					break
				}

				if(stop_con)
				{
					close(con)
					break
				}

				close(con)
			}
	}