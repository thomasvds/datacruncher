require 'csv'

# Create set of aliases for Hillary Clinton identifiers
HRC_ALIASES = ["H" ,";H", "Clinton", "Clinton Hillary R", "Clinton Rodham, Hillary", "H2",
  "Clinton, Hillary R", "Clinton, Hillary Rodham", "Hillary", "Hillary Rodham Clinton",
  "hr15@mycingular.blackberry.net", "HRC", "hrod17@clintonemail.com", "Madam Secretary",
  "Secretary", "Secretary Clinton", "Secretary Hillary R Clinton", "Secretary of State"]

Agent.destroy_all
Event.destroy_all

puts "starting"

# # Generate Hillary Clinton agent
hillary = Agent.create(name: "Hillary Clinton", picture_url: "https://yt3.ggpht.com/-eXKU4UhFusI/AAAAAAAAAAI/AAAAAAAAAAA/7AcPlXaWCoU/s100-c-k-no-mo-rj-c0xffffff/photo.jpg", position: "Secretary of State")
p "#{hillary.name} created"
p " ------- Hillary Id #{hillary.id} ----------"

counter = 0

# Generate events, taking all curated emails from the CSV file
CSV.foreach('db/curated_emails.csv', col_sep: "," , headers: :first_row) do |row|
  begin
    # Create counter for debugging purposes

    # If the sender is Hillary Clinton (or one if her aliases)
    if HRC_ALIASES.include?(row["From"])
          p counter += 1
      # Create a datetime object from date email is sent
      d =  DateTime.parse(row["Sent"])
      # Create event with required aatributes
      event = Event.create(source: 'HRC', category: 'communication', agent: Agent.where(name: "Hillary Clinton").first,
          date: d, year: d.year, week: d.cweek, day: d.wday, hour: d.hour
        )
      p "#{event.source} event created at #{d} for email nr #{counter}"
    end
  rescue
    p $!.message
  end
end

# # # Generate sets of pre-determined policies
p = Policy.create(name: "No work on weekends", timeframe: "on weekends", adverb: "at all")
PolicySetting.create(policy: p, weight: 0.5, enabled: true)

p = Policy.create(name: "No work after 8PM", timeframe: "on weekdays", adverb: "after", hour: 20)
PolicySetting.create(policy: p, weight: 0.125, enabled: true)

p = Policy.create(name: "No work after 10PM", timeframe: "on weekdays", adverb: "after", hour: 22)
PolicySetting.create(policy: p, weight: 0.125, enabled: true)

p = Policy.create(name: "Early Friday night", timeframe: "on Fridays", adverb: "after", hour: 18)
PolicySetting.create(policy: p, weight: 0.125, enabled: true)

p = Policy.create(name: "One free night per week", timeframe: "at least once from Monday to Thursday", adverb: "after", hour: 19)
PolicySetting.create(policy: p, weight: 0.125, enabled: true)
