require 'csv'

# csv cleaning utilities
def clean_date(dirty_date)
  date_regex = /\d{1,2}\s[a-zA-Z]{3}\s\d{4}\s\d{2}:\d{2}:\d{2}/
  date = dirty_date.scan(date_regex)[0]
  date.nil? ? nil : date
end

def enron_clean_name(dirty_name)
  name_regex = /([a-zA-Z\.]+(\s+[a-zA-Z\.]+)+)/
  name = dirty_name.scan(name_regex)[0][0]
  name.nil? ? nil : name
end

def gmail_clean_name(dirty_name)
  name_regex = /<(.+)>/
  p dirty_name
  name = dirty_name.scan(name_regex)[0]
  name.nil? ? dirty_name : name
end

Agent.destroy_all
Event.destroy_all

# generate employees, taking all "from" fields in the mails list
# names = []

# CSV.foreach('db/extract.csv', :col_sep => ";" , :quote_char => "\x00") do |row|
#   begin
#     dirty_name = row[1]
#     name =  clean_name(dirty_name)
#     names << name unless names.include?(name)
#   rescue
#     $!.message
#   end
# end

# names.each do |name|
#   Agent.create(name: name, picture_url: "https://unsplash.it/100/100", position: "Enron employee")
# end

Agent.create(name: "vanderstraeten.thomas@gmail.com", picture_url: "https://unsplash.it/100/100", position: "Entrepreneur")

# generate events, taking all mails in the mails list
CSV.foreach('db/extract.csv', :col_sep => ";" , :quote_char => "\x00") do |row|
  begin
    dirty_date = row[0]
    name = gmail_clean_name(row[1])
    if name = "vanderstraeten.thomas@gmail.com"
      d =  DateTime.parse(clean_date(dirty_date))
      Event.create(source: 'seed', category: 'communication', agent: Agent.where(name: name).first, date: d, year: d.year, week: d.cweek, day: d.wday, hour: d.hour)
    end
  rescue
    p $!.message
  end
end

# Generate policies
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
