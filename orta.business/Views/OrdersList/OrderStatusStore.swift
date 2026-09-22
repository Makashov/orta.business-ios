//
//  OrderStatusStore.swift
//  orta.business
//
//  Created by Nurbol Makashov on 22.09.2026.
//

import Foundation
import Observation

/// Tenant-wide order statuses fetched once from `/api/orders/statuses` and shared
/// via the environment, so the orders list, filters, swipe actions, and the
/// create/edit forms all resolve statuses against the same real definitions.
@Observable
final class OrderStatusStore {
    private(set) var statuses: [OrderStatus] = []
    private(set) var loadError: String?

    private let service: any OrdersServicing

    init(service: any OrdersServicing = LiveOrdersService()) {
        self.service = service
    }

    func load() async {
        guard statuses.isEmpty else { return }
        do {
            statuses = try await service.fetchStatuses()
            loadError = nil
        } catch {
            loadError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func status(id: Int) -> OrderStatus? {
        statuses.first { $0.id == id }
    }

    var initialStatus: OrderStatus? {
        statuses.first { $0.isInitial } ?? statuses.first
    }

    /// The terminal, non-cancelled status ("Completed"-equivalent) used when an
    /// order is finished from the edit screen.
    var completedStatus: OrderStatus? {
        statuses.first { $0.isTerminal && !$0.isCancelled } ?? statuses.first { $0.isTerminal }
    }
}
