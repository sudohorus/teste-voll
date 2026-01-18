users = []
5.times do |i|
  users << User.create!(
    name: "Usuario #{i + 1}",
    email: "usuario#{i + 1}@gmail.com",
    password: "usuario#{i + 1}"
  )
end


30.times do |i|
  sender = i.even? ? users[0] : users[1]
  receiver = i.even? ? users[1] : users[0]
  
  Message.create!(
    sender: sender,
    receiver: receiver,
    content: "Mensagem #{i + 1} de #{sender.name} para #{receiver.name}",
    created_at: Time.now - (30 - i).minutes
  )
end

5.times do |i|
  sender = i.even? ? users[0] : users[2]
  receiver = i.even? ? users[2] : users[0]
  
  Message.create!(
    sender: sender,
    receiver: receiver,
    content: "Olá #{receiver.name}, mensagem #{i + 1}",
    created_at: Time.now - (10 - i).minutes
  )
end
