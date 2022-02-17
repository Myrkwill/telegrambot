import Vapor
import telegram_vapor_bot

// configures your application
public func configure(_ app: Application) throws {
	// Connect telegram bot
	let connection: TGConnectionPrtcl = TGLongPollingConnection()
	TGBot.configure(connection: connection, botId: Environment.tgApi, vaporClient: app.client)
	try TGBot.shared.start()

	// Set level of debug if you needed
	TGBot.log.logLevel = .error

	DefaultBotHandlers.addHandlers(app: app, bot: TGBot.shared)
}
