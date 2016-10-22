crypt_client <- function(host_address = "localhost")
	{

#Loading Scripts

		source("Scripts/pkgTest.R")
		source("Scripts/submit_usr.R")
		source("Scripts/receive_r_object.R")
		source("Scripts/send_r_object.R")

#Loading Packages

		packages_to_load <- c("sodium")

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
					close(con)
					break
				}
				cat("\nPassword:\n")
				pass <- readLines(f, n=1)
				if(tolower(pass)=="q")
				{
					cat("\nExiting Server.\n\n")
					close(con)
					break
				}

				user_info <- submit_usr(user,pass)
				write_resp <- writeLines(user_info, con)


				server_resp <- readLines(con, 1)
#Auth Successful
				if(server_resp == "0")
				{
					cat("\nAuthenticated!\n\n")
					
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
							cat("\nData Object:\n\n",read_data,"\n")
							rm(read_data)
							rm(file_to_read)
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
								write_read_file <- writeLines("",con)

							}
							else
							{
								write_read_file <- writeLines(file_to_write,con)
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

						}
#Deleting Data
						else if(action=="4")
						{
							cat("\nData Deleted.\n")
						}
#Account Summary
						else if(action=="5")
						{
							cat("\nAccount Summary:\n")
						}
#Logout
						else if(action=="6")
						{
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
				else if(server_resp == "1")
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