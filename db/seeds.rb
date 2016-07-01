Agent.destroy_all
Event.destroy_all

Agent.create(name: 'Thomas', slack_id: 'U0AUD2XK4', github_id: '17250698')
Agent.create(name: 'Edouard', slack_id: 'U0BDES7NZ')
Agent.create(name: 'Guillaume', slack_id: 'U0C03E7N3')
Agent.create(name: 'Vincent', slack_id: 'U0ARWTYAK')
Agent.create(name: 'Adrien', github_id: '15191401')
Agent.create(name: 'Gauthier', github_id: '14982869')


date_from  = Date.parse('2016-04-01')

date_range = date_from..Date.today

date_range.each do |d|
  if (d.saturday? || d.sunday?)
    p = 0.1 #less likely that agents will work on week-ends
    q = 0.3 #even if there is work on the week-end, it is less than during the week
  else
    p = 1
    q = 1
  end
  Agent.all.each do |a|
    if rand(0) < p
      #go through the hours of the day, with a decreasing probability for work after hours
      (9..18).each do |h|
        if rand(0) < 0.5 * q
          if rand(0) < 0.3 then category = 'production' else category = 'communication' end
          Event.create(source: 'seed',category: category, agent: a, date: d, day: d.wday, hour: h)
        end
      end
      (19..20).each do |h|
        if rand(0) < 0.3 * q
          if rand(0) < 0.3 then category = 'production' else category = 'communication' end
          Event.create(source: 'seed',category: category, agent: a, date: d, day: d.wday, hour: h)
        end
      end
      (21..23).each do |h|
        if rand(0) < 0.1 * q
          if rand(0) < 0.3 then category = 'production' else category = 'communication' end
          Event.create(source: 'seed',category: category, agent: a, date: d, day: d.wday, hour: h)
        end
      end
    end
  end
end

Policy.create(name: "No work on weekends",
  weight: 0.5, enabled: true, timeframe: "on weekends", adverb: "at all")
Policy.create(name: "No work after 8PM",
  weight: 0.125, enabled: true, timeframe: "on weekdays", adverb: "after", hour: 20)
Policy.create(name: "No work after 10PM",
  weight: 0.125, enabled: true, timeframe: "on weekdays", adverb: "after", hour: 22)
Policy.create(name: "Early Friday night",
  weight: 0.125, enabled: true, timeframe: "on Fridays", adverb: "after", hour: 18)
Policy.create(name: "One free night per week",
  weight: 0.125, enabled: true, timeframe: "at least once from Monday to Thursday", adverb: "after", hour: 19)







