Rake::Task["spec"].enhance do
  Rake::Task["standard:fix"].execute
end
