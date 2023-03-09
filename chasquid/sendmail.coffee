#!/usr/bin/env coffee

> nodemailer

{user,to,pass,subject} = process.env

transporter = nodemailer.createTransport({
    host: 'smtp.user.tax'
    debug: true
    logger: true
    secure: true
    port: 465
    auth: {
      user
      pass
    }
})

subject = subject or "⭐ test mail from #{user} #{new Date().toISOString().slice(0,19).replace('T',' ')}"

mail = {
    from: user
    to
    subject
    text: subject
    html: '<h1>#{subject}</h1>'
}

console.log await transporter.sendMail(mail)
