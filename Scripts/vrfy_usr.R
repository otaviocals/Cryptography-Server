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
						print("Authenticated!")
						auth <- TRUE
						result <- 0
					}
					
				}
#No User End
				if(i==nrow(database) && usr_check==FALSE && usr_found==FALSE)
				{
					print("No User Found")
					result <- 1
				}

#Wrong Password End

				if(i==nrow(database) && usr_check==FALSE && usr_found==TRUE)
				{
					print("Wrong Password")
					result <- 1
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
			print("No Database")
			result <- 1000
		}

	result
	
	}