#!/usr/bin/env coffee

> nodemailer

transporter = nodemailer.createTransport({
    host: 'smtp.user.tax'
    debug: true
    logger: true
    secure: true
    port: 465
    auth: {
      user: 'i@user.tax'
      pass: process.env.password
    }
})

mail = {
    from: 'i@user.tax'
    to: 'iuser.link@gmail.com'
    subject: 'Hello ✔'+new Date
    text: 'text Hello world?'
    html: '<b>html Hello world?</b><h1>'+new Date+'</h1>'
}

console.log await transporter.sendMail(mail)
