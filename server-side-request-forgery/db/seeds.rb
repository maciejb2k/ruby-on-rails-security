Invoice.create!([
                  {
                    name: 'Invoice #2024-001',
                    issue_date: Date.new(2024, 3, 1),
                    url: 'http://example.com/invoices/2024-001.pdf',
                    raw_data: 'Raw PDF content for invoice #2024-001',
                    parsed_data: "Client: ABC Ltd.\nAmount: $1,200.00\nDue Date: 2024-03-15",
                    status: 'processed'
                  },
                  {
                    name: 'Invoice #2024-002',
                    issue_date: Date.new(2024, 3, 3),
                    url: 'http://example.com/invoices/2024-002.pdf',
                    raw_data: 'Raw PDF content for invoice #2024-002',
                    parsed_data: "Client: XYZ Corp.\nAmount: $850.00\nDue Date: 2024-03-17",
                    status: 'pending'
                  },
                  {
                    name: 'Invoice #2024-003',
                    issue_date: Date.new(2024, 3, 5),
                    url: 'http://example.com/invoices/2024-003.pdf',
                    raw_data: 'Raw PDF content for invoice #2024-003',
                    parsed_data: "Client: LMN Inc.\nAmount: $2,500.00\nDue Date: 2024-03-20",
                    status: 'failed'
                  }
                ])

