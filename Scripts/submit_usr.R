submit_usr <- function(input_usr,input_pass)
	{
		input_data <- data.frame("User" = bin2hex(sha512(charToRaw(input_usr))), "Pass" = bin2hex(sha512(charToRaw(input_pass))) )
		string_data <- paste0(toString(input_data[1,1]), toString(input_data[1,2]))
		string_data
	}