database_add <- function(user,pass,data="Data/user_data.csv")
	{

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


#Inputing Data

		input_data <- data.frame("User" = bin2hex(sha512(charToRaw(user))), "Pass" = bin2hex(sha512(charToRaw(pass))), "Init_Date" = toString(date()), "Last_Date" = toString(date()), "Last_Plat" = Sys.info()["sysname"], stringsAsFactors = FALSE, row.names = NULL)


		if(file.exists(data))
		{
			data_to_save <- read.csv(data)
			
			if(nrow(data_to_save)>0)
			{
				data_to_save <- rbind(data_to_save,input_data)
			}
			else
			{
				data_to_save <- input_data
			}
		}
		else
		{
			data_to_save <- input_data
		}

		write.csv(data_to_save,file = data, row.names = FALSE)
	}