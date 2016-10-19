pkgTest <- function(x)
	{
		if (!require(x,character.only = TRUE))
		{
			install.packages(x,dep=TRUE)
			if(!require(x,character.only = TRUE))
			{
				response <- FALSE
				print(paste0("Package ", x, " not found"))
			}
			else
			{
				response <- TRUE
			}
		}
		else
		{
			response <- TRUE
		}

		response
	}