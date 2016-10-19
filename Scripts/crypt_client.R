crypt_client <- function(host_address = "localhost")
	{
		while(TRUE)
			{
				con <- socketConnection(host=host_address, port = 6011, blocking=TRUE,server=FALSE, open="r+")
				f <- file("stdin")
				open(f)
				print("Enter text to be upper-cased, q to quit")
				sendme <- readLines(f, n=1)
				if(tolower(sendme)=="q")
					{
						break
					}
				write_resp <- writeLines(sendme, con)
				server_resp <- readLines(con, 1)
				print(paste("Your upper cased text:  ", server_resp))
				close(con)
			}
	}