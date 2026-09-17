local _, CF = ...
local W=CF.WindowTrim
local function borders()
  local result={}
  local mail,opened=_G.MailFrame,_G.OpenMailFrame
  if mail and mail.CloseButton and _G.InboxFrame and _G.SendMailFrame and
      InboxFrame:GetParent()==mail and SendMailFrame:GetParent()==mail then
    W:AddInset(result,mail,mail.Inset)
    W:AddInset(result,SendMailFrame,_G.SendMailMoneyInset)
  end
  if opened and opened.CloseButton and _G.OpenMailScrollFrame and
      OpenMailScrollFrame:GetParent()==opened then W:AddInset(result,opened,opened.Inset) end
  return result
end
CF:RegisterModule("MailWindow",W:New(borders,{"MAIL_SHOW","MAIL_INBOX_UPDATE","MAIL_SEND_INFO_UPDATE"},
  "Inbox/send, send-money and opened-mail inset trim; stationery, attachments, COD and all mail actions retained."))
