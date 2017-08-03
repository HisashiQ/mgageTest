Rails Version: 5.0.5
Ruby Version: 2.2.3

To run the program, simply cd into the root and run:

   bundle install
 
   rails db:create
 
   rails db:migrate
 
   rails db:import_txt SMS_DATA=/absolute/path/to/file.txt
    
   rails s

Visit localhost:3000 (or the port running the application if not 3000)


The approach to the problem was to design the model relationships first. 
The application has three models:
   Campaign
   Candidate
   Vote

The campaign has many candidates through votes and the candidates have many campaigns through votes. This allows queries such as Candidate.first.campaigns.
The assumption was that a candidate may occur in multiple campaigns.

A campaign controller was created as well as index and show views. The reason for creating a controller for the campaign model and not votes or candidates is to avoid calling external models inside controllers.
The application has an API, presenting the data in JSON format.

To parse the txt file and save the structured data in Postgres, a rake task was design. The reason the script was written as a rake task is to give the script access to Active Record and application gems.
One gem that was used to save the data was Active Record Import. This gem makes bulk inserts into postgres. Should a normal "Model.new(attribute: data) Model.save" call be made to active record for each vote, it is possible that this script would make over 10000 SQL insert statements. However, using Active Record Import, one insert statement is made for multiple votes, reducing DB queries and increasing speed and efficiency.

The design of the script is quite simple. The file is opened and all of the candidates and campaigns that exist in the database are loaded into two respective hashes (ID: Name)
Each line of the file is read and checked for encoding validity. If the candidate doesn't exist in the database then it is added. The same goes for each campaign. Then the structure of each line is checked via regEx and the candidates and campaign in the database are loaded into memory once again to retrieve the ID's of the newly added records. If the message was sent too early or too late then the campaign errors_count is incremented and updated. If not then a hash of vote records is updated.

Finally, if the structure of the line or the encoding is not valid, then the discarded errors integer is incremented to display errors at the end of the program. Once all lines are parsed, then the hash of vote records is used to form a single insert statement.

Factory Girl, rSpec and Faker were used to generate data and write tests. This application has one controller with two very simple methods so it was not tested. Generally, I would use cucumber to test controllers and views if I were to do this, although it seems a little overkill for this project.

NOTE: Normally, Environment variable would be used for test and development secret keys. However, as this is a code test, it is easier to run without having to add environment variables.

