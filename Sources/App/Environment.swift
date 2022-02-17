import Vapor

extension Environment {

	enum Key: String {
		case hostname
		case port
		case tgApi = "telegramApi"
	}

	static func get(_ key: Key) -> String {
		guard let value = Self.get(key.rawValue) else {
			fatalError("Environment \(key.rawValue) variable not found")
		}

		return value
	}

	/// Host name the server
	static var hostname: String {
		return get(.hostname)
	}

	/// Port the server
	static var port: Int {
		return Int(get(.port)) ?? 80
	}

	/// Telegram bot API
	static var tgApi: String {
		return get(.tgApi)
	}

}

