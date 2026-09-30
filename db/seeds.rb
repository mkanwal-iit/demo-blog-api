# Seed data for development and for the deployed demo.
#
# Deliberately free of Faker: the gem belongs to the :development, :test bundle
# group and is not installed in production, where this file also has to run.
#
# Idempotent — find_or_create_by! means re-running this will not duplicate rows.

peter = User.find_or_create_by!(email: "peter@example.com") do |user|
  user.name = "Peter"
  user.password = "password"
end

test_user = User.find_or_create_by!(email: "test@example.com") do |user|
  user.name = "Test"
  user.password = "password"
end

POSTS = [
  {
    title: "Why I started keeping a debugging journal",
    body: "Every time I fix something non-obvious, I write down what I expected, what actually happened, and what the gap turned out to be. Three months in, the surprising part is how often I reach for it. The same classes of bug recur, and past me has usually already done the hard thinking."
  },
  {
    title: "Reading a stack trace from the bottom up",
    body: "The top of a stack trace tells you where the program gave up. The bottom tells you where it started. The interesting line is usually the last one that belongs to your own code rather than the framework's, and that is the line worth reading first."
  },
  {
    title: "Continuous integration found four bugs in an afternoon",
    body: "The pipeline had been sitting in the repository unused for months. Once it ran, it turned up a missing version file, a test that had drifted out of sync with its endpoint, a lint sweep nobody had run, and a framework version that had quietly gone end of life."
  },
  {
    title: "Environment variables, and why the database URL is not in the code",
    body: "The same application runs on a laptop, in a CI container, and on a production server. What changes between them is not the code but the environment it reads at boot. Once that clicks, configuration stops feeling like boilerplate."
  },
  {
    title: "The works-on-my-machine trap",
    body: "A scan passed locally and failed in CI. The cause was a binstub that injected an extra flag, so the two commands were never really the same command. Reproducing a failure means running exactly what the pipeline runs, not something close to it."
  },
  {
    title: "Notes on upgrading a major framework version",
    body: "Branch first. Change the version constraint, let the dependency resolver do the work, then run the test suite before believing any of it. The tests are what turn an upgrade from a leap of faith into a routine change."
  },
  {
    title: "What a pull request is actually for",
    body: "It is not paperwork. It is the checkpoint where automated checks run against a change in isolation, before it reaches the branch everyone else builds on. Seeing four green checks before merging is the entire point."
  },
  {
    title: "Small commits, honest messages",
    body: "A commit message that says what changed and why is a note to whoever reads it next, including yourself in six months. It costs thirty seconds to write and saves considerably more than that later."
  },
  {
    title: "On reading error messages literally",
    body: "A message said a tool was not the latest version. I assumed it was a harmless notice and went looking for the real problem underneath. It was the real problem. The message had been accurate and specific the whole time."
  }
].freeze

POSTS.each_with_index do |attrs, index|
  author = index < 6 ? peter : test_user

  Post.find_or_create_by!(title: attrs[:title]) do |post|
    post.user_id = author.id
    post.body = attrs[:body]
    post.image = "https://picsum.photos/640/480?random=#{index + 1}"
  end
end

puts "Seeded #{User.count} users and #{Post.count} posts."
