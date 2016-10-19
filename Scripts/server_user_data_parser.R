server_user_data_parser <- function(user_data)
	{
		user_hash <- substr(user_data,1,128)
		pass_hash <- substr(user_data,129,256)

		input_data <- data.frame("User" = user_hash, "Pass" = pass_hash )

		input_data
	}