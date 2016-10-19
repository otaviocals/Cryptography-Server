database_add <- function(user,pass,data=user_data)
	{

		input_data <- data.frame("User" = bin2hex(sha512(charToRaw(user))), "Pass" = bin2hex(sha512(charToRaw(pass))) )

		if(exists("user_data") && nrow(data)>0)
		{
			data <- rbind(data,input_data)
		}
		else
		{
			data <- input_data
		}

		data
	}