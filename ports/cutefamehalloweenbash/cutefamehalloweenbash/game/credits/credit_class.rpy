## Used by the credit templates with for-loops
# This file contaisn the two classes "Credit" and "CategorisedCredits"

# Python code. Init number itself is not that important, but they incluence the order of code. I believe the default is usually at -1, so a smaller number goes earlier.
init -5 python:

    ## Credit Class
    class Credit:

        # constructor
        def __init__(self, name, role, image_name, url_list):            
            self.name = name
            self.role = role
            self.image_name = image_name 
            self.url_list = url_list


    ## CategorisedCredits class
    class CategorisedCredits:

        # constructor
        def __init__(self, category, credit_list):            
            self.category = category
            self.credit_list = credit_list