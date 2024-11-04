import type { RowDataPacket } from "mysql2/promise";

export interface PaginationInfo extends RowDataPacket {
   total_pages: number;
   has_prev: boolean;
   has_next: boolean;
}
