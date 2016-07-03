Agent.destroy_all
Event.destroy_all

Agent.create(name: 'Thomas', slack_id: 'U0AUD2XK4', github_id: '17250698')
Agent.create(name: 'Edouard', slack_id: 'U0BDES7NZ')
Agent.create(name: 'Guillaume', slack_id: 'U0C03E7N3')
Agent.create(name: 'Vincent', slack_id: 'U0ARWTYAK')
Agent.create(name: 'Adrien', github_id: '15191401')
Agent.create(name: 'Gauthier', github_id: '14982869')
Agent.create(name: 'John', github_id: '14982869')
Agent.create(name: 'Sam', github_id: '14982869')
Agent.create(name: 'Claire', github_id: '14982869')
Agent.create(name: 'Cécile', github_id: '14982869')
Agent.create(name: 'Alice', github_id: '14982869')
Agent.create(name: 'Eric', github_id: '14982869')
Agent.create(name: 'Mark', github_id: '14982869')


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
          Event.create(source: 'seed',category: category, agent: a, date: d, week: d.cweek, day: d.wday, hour: h)
        end
      end
      (19..20).each do |h|
        if rand(0) < 0.3 * q
          if rand(0) < 0.3 then category = 'production' else category = 'communication' end
          Event.create(source: 'seed',category: category, agent: a, date: d, week: d.cweek, day: d.wday, hour: h)
        end
      end
      (21..23).each do |h|
        if rand(0) < 0.1 * q
          if rand(0) < 0.3 then category = 'production' else category = 'communication' end
          Event.create(source: 'seed',category: category, agent: a, date: d, week: d.cweek, day: d.wday, hour: h)
        end
      end
    end
  end
end

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
