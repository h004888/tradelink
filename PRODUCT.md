# Product

## Register

product

## Users

- **Buyers** — Người mua trên nền tảng C2C. Họ tìm kiếm sản phẩm, thực hiện thanh toán qua escrow, theo dõi trạng thái giao dịch, và xác nhận nhận hàng để giải phóng tiền.
- **Sellers** — Người bán đăng listing sản phẩm, quản lý giao dịch đang diễn ra, phản hồi yêu cầu từ buyer, và nhận tiền sau khi giao dịch hoàn tất.
- **Admins/Support** — Nhân viên vận hành nền tảng, xử lý tranh chấp giữa buyer và seller, xác minh người dùng, và duy trì chất lượng marketplace.

Tất cả người dùng tương tác trong ngữ cảnh giao dịch tài chính có rủi ro — họ cần sự rõ ràng tuyệt đối về trạng thái giao dịch, dòng tiền, và trách nhiệm của mỗi bên.

## Product Purpose

TradeLink là nền tảng giao dịch C2C (consumer-to-consumer), hoạt động như một bên trung gian trung lập và đáng tin cậy giữa người mua và người bán. Nền tảng tạo ra môi trường giao dịch minh bạch, nơi cả hai bên đều được bảo vệ bởi cơ chế escrow.

**Job to be done:** Giúp người dùng thực hiện giao dịch C2C an toàn — từ khám phá sản phẩm, thương lượng, đến thanh toán escrow và xác nhận hoàn tất — mà không cần lo lắng về rủi ro lừa đảo hay mất tiền.

**Success:** Mỗi giao dịch hoàn tất thành công, cả buyer và seller đều cảm thấy được bảo vệ và informed xuyên suốt quá trình. Không có giao dịch nào rơi vào trạng thái "không rõ ràng".

## Brand Personality

**Reliable, Secure, Transparent** — TradeLink là bên trung gian trung lập nhưng vững chắc. Giọng điệu chuyên nghiệp, không khoa trương, không "cool ngầu". Cảm xúc hướng tới là "peace of mind" — sự an tâm như khi giao dịch qua ngân hàng tổ chức, nhưng với tốc độ và khả năng tiếp cận của một marketplace số hiện đại.

## Anti-references

- **Casual marketplace apps** (như Facebook Marketplace, Carousell): Quá informal, thiếu cảm giác an toàn cho giao dịch tài chính
- **Gamified fintech** (như Robinhood): Quá vui tươi, confetti, gamification — không phù hợp với giao dịch C2C nghiêm túc
- **Crypto/Web3 aesthetics**: Quá tối, quá "tech-bro", thiếu sự tin cậy của tài chính truyền thống
- **Navy-and-gold fintech cliché**: Màu xanh navy + vàng kim là công thức mặc định quá phổ biến trong fintech
- **Heavy shadows / neumorphism**: Cảm giác nổi mềm, không phù hợp với giao diện "vững chắc, có cấu trúc"

## Design Principles

1. **Radical transparency** — Mọi trạng thái giao dịch phải hiển thị rõ ràng. Người dùng không bao giờ phải đoán "tiền của tôi đang ở đâu" hay "ai đang chịu trách nhiệm bước tiếp theo".

2. **Structure over decoration** — Grid system chặt chẽ, whitespace chất lượng cao, phân cấp thông tin rõ ràng. Không dùng đồ họa trang trí hoặc hiệu ứng "làm đẹp" không mang ý nghĩa chức năng.

3. **One screen, one decision** — Mỗi màn hình chỉ yêu cầu người dùng đưa ra một quyết định chính. Giảm cognitive load trong các workflow tài chính phức tạp.

4. **Institutional trust, digital speed** — Giao diện mang lại cảm giác an toàn của ngân hàng tổ chức (cấu trúc, rõ ràng, bảo thủ về màu sắc), nhưng tương tác nhanh và responsive như một ứng dụng hiện đại.

5. **Neutral mediator** — Giao diện không thiên vị bên nào. UI phục vụ cả buyer và seller với cùng mức độ quan tâm và rõ ràng.

## Accessibility & Inclusion

- **WCAG AA** — Tỷ lệ tương phản tối thiểu 4.5:1 cho body text, 3:1 cho large text
- Focus visible trên tất cả interactive elements
- Semantic structure rõ ràng cho screen readers
- Hỗ trợ `prefers-reduced-motion` cho người dùng nhạy cảm với chuyển động
- Cân nhắc color blindness: không chỉ dùng màu sắc để truyền đạt thông tin trạng thái (kết hợp icon + text)
- `tabular-nums` cho tất cả giá trị tiền tệ để số liệu thẳng hàng trong bảng giao dịch
