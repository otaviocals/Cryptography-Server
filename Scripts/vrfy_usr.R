vrfy_usr <- function(input_data,database=user_data)
	{

		auth <- FALSE
		usr_found <- FALSE


		if(nrow(database)>0)
		{
			for(i in 1:nrow(database))
			{

				usr_check <- identical(toString(input_data[[1]]),toString(database[i,1]))

				if(usr_check)
				{

					usr_found <- TRUE

					pass_check <- identical(toString(input_data[[2]]),toString(database[i,2]))
					if(pass_check)
					{
						writeLines("Authenticated!")
						auth <- TRUE
						result <- i
					}
					
				}
#No User End
				if(i==nrow(database) && usr_check==FALSE && usr_found==FALSE)
				{
					writeLines("No User Found")
					result <- 0
				}

#Wrong Password End

				if(i==nrow(database) && usr_check==FALSE && usr_found==TRUE)
				{
					writeLines("Wrong Password")
					result <- 0
				}
#Succesful Auth End
				if(auth)
				{
					break()
				}
			}
		}

#No Database
		else
		{
			writeLines("No Database")
			result <- -1000
		}

	result
	
	}