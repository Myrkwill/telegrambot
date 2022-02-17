import Vapor
import telegram_vapor_bot

// configures your application
public func configure(_ app: Application) throws {

	app.http.server.configuration.hostname = Environment.hostname
	app.http.server.configuration.port = Environment.port

	let connection: TGConnectionPrtcl = TGLongPollingConnection()
	TGBot.configure(connection: connection, botId: Environment.tgApi, vaporClient: app.client)
	try TGBot.shared.start()

	/// set level of debug if you needed
	TGBot.log.logLevel = .error

	DefaultBotHandlers.addHandlers(app: app, bot: TGBot.shared)

    // register routes
    try routes(app)
}
