import Vapor
import telegram_vapor_bot

struct T: Decodable {
	let text: String

}

final class DefaultBotHandlers {

	static func addHandlers(app: Vapor.Application, bot: TGBotPrtcl) {
		defaultHandler(app: app, bot: bot)
		commandPingHandler(app: app, bot: bot)
		commandCatHandler(app: app, bot: bot)
		commandShowButtonsHandler(app: app, bot: bot)
		buttonsActionHandler(app: app, bot: bot)
		commandShowButtons1Handler(app: app, bot: bot)
	}


	private static func commandCatHandler(app: Vapor.Application, bot: TGBotPrtcl) {
		let handler = TGCommandHandler(commands: ["/cat"]) { update, bot in
			app.http.client.shared.get(url: "https://cat-fact.herokuapp.com/facts").whenSuccess { result in
				guard let body = result.body, let data = body.getData(at: 0, length: body.readableBytes) else {
					return
				}
				let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
				guard let jsonArray = jsonResponse as? [[String: Any]],
					  let title = jsonArray.randomElement()?["text"] as? String else {
					  return
				}
				try? update.message?.reply(text: title, bot: bot)
			}
		}
		bot.connection.dispatcher.add(handler)
	}



	private static func defaultHandler(app: Vapor.Application, bot: TGBotPrtcl) {
		let handler = TGMessageHandler(filters: (.all && !.command.names(["/ping"]))) { update, bot in
			// let params: TGSendMessageParams = .init(chatId: .chat(update.message!.chat.id), text: "Success")
			// try bot.sendMessage(params: params)
			if let mediaID =  update.message?.photo?.last?.fileId {
				try? bot.getFile(params: TGGetFileParams(fileId: mediaID)).whenSuccess({ file in
					guard let filePath = file.filePath else {
						return
					}
					let url = "https://api.telegram.org/file/bot\(tgApi)/\(filePath)"
					try? update.message?.reply(text: url, bot: bot)
				})
			}

		}
		bot.connection.dispatcher.add(handler)
	}

	private static func commandPingHandler(app: Vapor.Application, bot: TGBotPrtcl) {
		let handler = TGCommandHandler(commands: ["/ping"]) { update, bot in
			try update.message?.reply(text: "Первое сообщение", bot: bot)
			try update.message?.reply(text: "Второе сообщение", bot: bot)
		}
		bot.connection.dispatcher.add(handler)
	}

	/// add handler for command "/show_buttons" - show message with buttons
	private static func commandShowButtonsHandler(app: Vapor.Application, bot: TGBotPrtcl) {
		let handler = TGCommandHandler(commands: ["/show_buttons"]) { update, bot in
			guard let userId = update.message?.from?.id else { fatalError("user id not found") }
			let buttons: [[TGInlineKeyboardButton]] = [
				[.init(text: "Button 1", callbackData: "press 1"), .init(text: "Button 2", callbackData: "press 2")]
			]
			let keyboard: TGInlineKeyboardMarkup = .init(inlineKeyboard: buttons)
			let params: TGSendMessageParams = .init(chatId: .chat(userId),
													text: "Keyboard activ",
													replyMarkup: .inlineKeyboardMarkup(keyboard))
			try bot.sendMessage(params: params)
		}
		bot.connection.dispatcher.add(handler)
	}

	private static func commandShowButtons1Handler(app: Vapor.Application, bot: TGBotPrtcl) {
		let handler = TGCommandHandler(commands: ["/show_buttons1"]) { update, bot in
			guard let userId = update.message?.from?.id else { fatalError("user id not found") }
			let buttons: [[TGKeyboardButton]] = [
				[.init(text: "Привет"), .init(text: "Пока")]
			]
			let keyboard: TGReplyKeyboardMarkup = .init(keyboard: buttons)
			let params: TGSendMessageParams = .init(chatId: .chat(userId),
													text: "",
													replyMarkup: .replyKeyboardMarkup(keyboard))
			try bot.sendMessage(params: params)
		}
		bot.connection.dispatcher.add(handler)
	}

	/// add two handlers for callbacks buttons
	private static func buttonsActionHandler(app: Vapor.Application, bot: TGBotPrtcl) {
		let handler = TGCallbackQueryHandler(pattern: "press 1") { update, bot in
			let params: TGAnswerCallbackQueryParams = .init(callbackQueryId: update.callbackQuery?.id ?? "0",
															text: update.callbackQuery?.data  ?? "data not exist",
															showAlert: nil,
															url: nil,
															cacheTime: nil)
			try bot.answerCallbackQuery(params: params)
		}

		let handler2 = TGCallbackQueryHandler(pattern: "press 2") { update, bot in
			let params: TGAnswerCallbackQueryParams = .init(callbackQueryId: update.callbackQuery?.id ?? "0",
															text: update.callbackQuery?.data  ?? "data not exist",
															showAlert: nil,
															url: nil,
															cacheTime: nil)
			try bot.answerCallbackQuery(params: params)
		}

		bot.connection.dispatcher.add(handler)
		bot.connection.dispatcher.add(handler2)
	}
}
