crypt_client <- function(host_address = "localhost")
	{

#Loading Scripts

		source("Scripts/pkgTest.R")
		source("Scripts/submit_usr.R")

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
					break
				}
				cat("\nPassword:\n")
				pass <- readLines(f, n=1)
				if(tolower(pass)=="q")
				{
					break
				}

				user_info <- submit_usr(user,pass)
				write_resp <- writeLines(user_info, con)


				server_resp <- readLines(con, 1)
				if(server_resp == "0")
				{
					cat("\nAuthenticated!\n\n")
					break
				}
				else if(server_resp == "1")
				{
					cat("\nUser or Password is wrong.\n\n")
				}
				else
				{
					cat("\nServer Error\n\n")
				}


				close(con)
			}
	}