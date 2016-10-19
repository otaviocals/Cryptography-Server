crypt_client_write <- function(host = "localhost",data)
	{
		port <- 32323
		socket <- make.socket(host, port)
		on.exit(close.socket(socket))
		write.socket(socket,string=toString(data))

	}