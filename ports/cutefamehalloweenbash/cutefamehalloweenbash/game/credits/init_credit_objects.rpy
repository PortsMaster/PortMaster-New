## Define the people who should appear in the credits as Credit objects  
# url_list is a list of tuple with 'site icon image' and 'clickable url element'. 
# Here the url is the same as the text string that's printed, add another tuple if you want to print different text for clickable url.

# uncategorised credit list that is used in template 1b and 2b
define credit_list = [
    # Me! Fame.
    Credit(name = "Fame/Cute Fame Studio", role = "Manager, Script Writer & Programming", image_name = "credits/cutefame.png", url_list = [
        ("Itch-io", "https://cutefame.itch.io/"), 
        ("Website", "https://cutefame.net")
    ]),
    # Name 2 (Has no logos for testing purposes)
    Credit(name = "Name 2 (no logos)", role = "(Placeholder)", image_name = None, url_list = [
        (None, "https://www.twitter.com/gaming_v_potato/")
    ]),
    # Name 3
    Credit(name = "Name 3", role = "(Placeholder)", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    # Name 4
    Credit(name = "Name 4", role = "(Placeholder)", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    # Name 5
    Credit(name = "Name 5", role = "(Placeholder)", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    # Name 6
    Credit(name = "Name 6", role = "(Placeholder)", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    # Name 7
    Credit(name = "Name 7", role = "(Placeholder)", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ])
]

############################################################################################################################################

# credit lists that are split into categories that are used in template 2c

define director_credits_list = [
    Credit(name = "Gaming Variety Potato", role = "Director", image_name = "logo", url_list = [
        ("itch-io", "https://gaming-variety-potato.itch.io/"), 
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ])
]

define writing_credits_list = [
    Credit(name = "Gaming Variety Potato", role = "Writer", image_name = "logo", url_list = [
        ("itch-io", "https://gaming-variety-potato.itch.io/"), 
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Artist", image_name = "logo", url_list = [
        ("itch-io", "https://gaming-variety-potato.itch.io/"), 
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ])
]

define art_credits_list = [
    Credit(name = "Gaming Variety Potato", role = "Artist", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Artist", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Artist", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Artist", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Artist", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ])
]

define audio_credits_list = [
    Credit(name = "Gaming Variety Potato", role = "Musician", image_name = "logo", url_list = [
        ("itch-io", "https://www.twitter.com/gaming_v_potato/"), 
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Musician", image_name = "logo", url_list = [
        ("itch-io", "https://www.twitter.com/gaming_v_potato/"), 
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Musician", image_name = "logo", url_list = [
        ("itch-io", "https://www.twitter.com/gaming_v_potato/"), 
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ])
]

define programming_credits_list = [
    Credit(name = "Gaming Variety Potato", role = "Programmer", image_name = "logo", url_list = [
        ("itch-io", "https://gaming-variety-potato.itch.io/"), 
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "QA", image_name = "logo", url_list = [
        ("itch-io", "https://gaming-variety-potato.itch.io/"), 
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
]

define va_credits_list = [
    Credit(name = "Gaming Variety Potato", role = "Character 1 Voice", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Character 2 Voice", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Character 3 Voice", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Character 4 Voice", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Character 5 Voice", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Character 6 Voice", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Character 7 Voice", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
    Credit(name = "Gaming Variety Potato", role = "Character 8 Voice", image_name = "logo", url_list = [
        ("twitter-original", "https://www.twitter.com/gaming_v_potato/")
    ]),
]

define categorised_credits_list = [
    # item 1: category Director
    CategorisedCredits(category = "Director", credit_list = director_credits_list),
    # item 2: category Writing
    CategorisedCredits(category = "Writing", credit_list = writing_credits_list),
    # item 3: category Art
    CategorisedCredits(category = "Art", credit_list = art_credits_list),
    # item 4: category Audio
    CategorisedCredits(category = "Audio", credit_list = audio_credits_list),
    # item 5: category Programming
    CategorisedCredits(category = "Programming", credit_list = programming_credits_list),
    # item 6: category VA
    CategorisedCredits(category = "VA", credit_list = va_credits_list),
]
