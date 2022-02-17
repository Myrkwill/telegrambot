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

	static var hostname: String {
		return get(.hostname)
	}

	static var port: Int {
		return Int(get(.port)) ?? 80
	}

	static var tgApi: String {
		return get(.tgApi)
	}

}

