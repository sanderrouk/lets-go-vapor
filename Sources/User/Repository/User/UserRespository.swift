import Vapor
import FluentSQLite
import Data

public protocol UserRepository: Service {
    func createOrUpdate(user: User) -> Future<User>
}

public class UserRepositoryImpl: UserRepository {
    private let databaseConnection: SQLiteDatabase.ConnectionPool

    required init(databaseConnection:  SQLiteDatabase.ConnectionPool) {
        self.databaseConnection = databaseConnection
    }

    public func createOrUpdate(user: User) -> EventLoopFuture<User> {
        return databaseConnection.withConnection { connection in
            return user.save(on: connection)
        }
    }
}

extension UserRepositoryImpl: ServiceType {
    public static let serviceSupports: [Any.Type] = [UserRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        let connectionPool = try worker.connectionPool(to: .sqlite)
        return .init(databaseConnection: connectionPool)
    }
}
