---
version: alpha
name: TradeLink Core Design System
description: Hệ thống nhận diện và nền tảng giao diện cho TradeLink — nền tảng mua bán C2C đáng tin cậy, minh bạch và an toàn.
colors:
  primary: "#2563EB"
  primary-hover: "#1D4ED8"
  trust-teal: "#14B8A6"
  payment-held: "#0F766E"
  success: "#16A34A"
  warning: "#F59E0B"
  error: "#DC2626"
  info: "#0284C7"
  neutral: "#CBD5E1"
  dark: "#0F172A"
  dark-surface: "#172033"
  surface: "#FFFFFF"
  background: "#F8FAFC"
  text-primary: "#0F172A"
  text-secondary: "#64748B"
  text-muted: "#94A3B8"
  text-on-dark: "#F8FAFC"
  border-subtle: "#E2E8F0"
  transparent: "transparent"
typography:
  display-1:
    fontFamily: SF Pro Display, Inter, sans-serif
    fontSize: 34px
    fontWeight: 700
    lineHeight: 40px
    letterSpacing: -0.02em
  display-2:
    fontFamily: SF Pro Display, Inter, sans-serif
    fontSize: 28px
    fontWeight: 700
    lineHeight: 34px
    letterSpacing: -0.015em
  heading-1:
    fontFamily: SF Pro Display, Inter, sans-serif
    fontSize: 22px
    fontWeight: 600
    lineHeight: 28px
    letterSpacing: -0.01em
  heading-2:
    fontFamily: SF Pro Display, Inter, sans-serif
    fontSize: 18px
    fontWeight: 600
    lineHeight: 24px
    letterSpacing: -0.005em
  body-1:
    fontFamily: SF Pro Text, Inter, sans-serif
    fontSize: 16px
    fontWeight: 400
    lineHeight: 24px
    letterSpacing: 0em
  body-2:
    fontFamily: SF Pro Text, Inter, sans-serif
    fontSize: 14px
    fontWeight: 400
    lineHeight: 20px
    letterSpacing: 0em
  caption:
    fontFamily: SF Pro Text, Inter, sans-serif
    fontSize: 12px
    fontWeight: 400
    lineHeight: 16px
    letterSpacing: 0em
  label:
    fontFamily: SF Pro Text, Inter, sans-serif
    fontSize: 14px
    fontWeight: 600
    lineHeight: 20px
    letterSpacing: 0em
  price:
    fontFamily: SF Pro Display, Inter, sans-serif
    fontSize: 20px
    fontWeight: 700
    lineHeight: 26px
    letterSpacing: -0.01em
    fontFeature: "tnum"
rounded:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  full: 9999px
spacing:
  1: 4px
  2: 8px
  3: 12px
  4: 16px
  5: 20px
  6: 24px
  8: 32px
  10: 40px
  16: 64px
  base-grid: 8px
  micro-step: 4px
  touch-target-min: 44px
components:
  logo-mark:
    primaryColor: "{colors.primary}"
    secondaryColor: "{colors.trust-teal}"
    backgroundColor: "{colors.transparent}"
  app-icon:
    backgroundColor: "{colors.surface}"
    primaryColor: "{colors.primary}"
    secondaryColor: "{colors.trust-teal}"
    rounded: "{rounded.lg}"
    padding: 12px
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    height: 48px
    padding: 16px
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
    textColor: "{colors.surface}"
  button-secondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    borderColor: "{colors.primary}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    height: 48px
    padding: 16px
  button-destructive:
    backgroundColor: "{colors.error}"
    textColor: "{colors.surface}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    height: 48px
    padding: 16px
  input-default:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    borderColor: "{colors.border-subtle}"
    typography: "{typography.body-1}"
    rounded: "{rounded.md}"
    height: 48px
    padding: 12px
  input-focus:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    borderColor: "{colors.primary}"
  input-error:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    borderColor: "{colors.error}"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    borderColor: "{colors.border-subtle}"
    rounded: "{rounded.lg}"
    padding: 16px
    boxShadow: "0 4px 12px rgba(15, 23, 42, 0.08)"
  card-compact:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
    padding: 12px
    boxShadow: "0 1px 2px rgba(15, 23, 42, 0.05)"
  card-elevated:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.xl}"
    padding: 24px
    boxShadow: "0 12px 32px rgba(15, 23, 42, 0.12)"
  status-protected:
    backgroundColor: "{colors.payment-held}"
    textColor: "{colors.surface}"
    rounded: "{rounded.full}"
    typography: "{typography.caption}"
    padding: 8px
  status-success:
    backgroundColor: "{colors.success}"
    textColor: "{colors.surface}"
    rounded: "{rounded.full}"
    typography: "{typography.caption}"
    padding: 8px
  status-warning:
    backgroundColor: "{colors.warning}"
    textColor: "{colors.dark}"
    rounded: "{rounded.full}"
    typography: "{typography.caption}"
    padding: 8px
  status-error:
    backgroundColor: "{colors.error}"
    textColor: "{colors.surface}"
    rounded: "{rounded.full}"
    typography: "{typography.caption}"
    padding: 8px
  icon-base:
    textColor: "{colors.dark}"
    size: 24px
    strokeWidth: 2px
    strokeLinecap: round
    strokeLinejoin: round
---

# TradeLink Design System

## Overview

TradeLink mang phong cách **hiện đại, đáng tin cậy, an toàn và hướng đến cộng đồng**. Hệ thống hình ảnh phải giúp người dùng cảm nhận rằng họ đang giao dịch với người thật trong một môi trường minh bạch, có cơ chế bảo vệ rõ ràng.

Ba giá trị cốt lõi:

- **Đáng tin cậy:** Minh bạch, rõ ràng trong thông tin, trạng thái và hành động.
- **An toàn:** Tiền và giao dịch được bảo vệ; các trạng thái tài chính phải được diễn đạt chính xác.
- **Cộng đồng:** Kết nối người mua và người bán thật, tạo cảm giác gần gũi nhưng vẫn chuyên nghiệp.

Logo sử dụng biểu tượng hai mắt xích liên kết, kết hợp **Protection Blue** và **Trust Teal**. Biểu tượng có thể dùng độc lập làm app icon; wordmark `TradeLink` dùng màu Dark Navy. Không làm biến dạng, xoay, đổi thứ tự màu hoặc thêm hiệu ứng trang trí vào logo.

Giao diện ưu tiên:

- Nền sáng, sạch và thoáng.
- Hệ thống phân cấp rõ ràng.
- Một hành động chính nổi bật trên mỗi màn hình.
- Trạng thái phải đi cùng màu, biểu tượng và nhãn chữ; không truyền đạt ý nghĩa chỉ bằng màu sắc.
- Hình khối mềm mại nhưng không quá vui nhộn hoặc hoạt hình.

## Colors

Bảng màu TradeLink kết hợp xanh dương bảo vệ, xanh teal tin cậy và các màu ngữ nghĩa có vai trò cố định.

### Brand colors

- **Primary — Protection Blue (`#2563EB`):** Hành động chính, liên kết quan trọng, trạng thái điều hướng đang hoạt động và điểm nhấn thương hiệu.
- **Primary Hover (`#1D4ED8`):** Trạng thái hover, pressed hoặc selected đậm của Primary.
- **Trust Teal (`#14B8A6`):** Nửa thứ hai của logo, các điểm nhấn liên quan đến niềm tin, bảo vệ và xác minh.
- **Payment Held (`#0F766E`):** Dành riêng cho trạng thái tiền đang được giữ hoặc giao dịch đang được bảo vệ.

### Semantic colors

- **Success (`#16A34A`):** Hoàn tất, thành công, đã xác minh.
- **Warning (`#F59E0B`):** Chờ xử lý, hạn chót, hành động sắp đến hạn.
- **Error (`#DC2626`):** Lỗi, hủy, tranh chấp, hạn chế hoặc hành động phá hủy.
- **Info (`#0284C7`):** Thông tin hệ thống và hướng dẫn trung lập.
- **Neutral (`#CBD5E1`):** Trạng thái chưa hoạt động, đường phân cách và thành phần bị vô hiệu hóa.

### Neutral surfaces

- **Dark (`#0F172A`):** Tiêu đề, nội dung chính, wordmark và nền tối chủ đạo.
- **Dark Surface (`#172033`):** Bề mặt tối thứ cấp.
- **Surface (`#FFFFFF`):** Card, modal, input và các bề mặt nổi.
- **Background (`#F8FAFC`):** Nền chính của ứng dụng.
- **Text Secondary (`#64748B`):** Nội dung phụ, mô tả và metadata.
- **Text Muted (`#94A3B8`):** Placeholder hoặc nội dung ưu tiên thấp; không dùng cho thông tin quan trọng.

### Usage rules

- Chỉ dùng Primary cho CTA quan trọng nhất hoặc trạng thái điều hướng chính.
- Không dùng xanh lá để trang trí; xanh lá luôn biểu thị thành công hoặc xác minh.
- Không dùng đỏ cho thông báo trung lập.
- Không dùng `payment-held` cho nội dung không liên quan đến tiền đang được bảo vệ.
- Giá, hạn chót và trạng thái giao dịch phải đạt độ tương phản WCAG AA.

## Typography

TradeLink sử dụng **SF Pro Display / SF Pro Text**, với **Inter** làm phương án thay thế đa nền tảng. Cả hai phải hỗ trợ đầy đủ dấu tiếng Việt.

- **Display 1 — 34/40, Bold:** Tiêu đề hero hoặc tiêu đề cấp cao nhất.
- **Display 2 — 28/34, Bold:** Tiêu đề màn hình quan trọng.
- **Heading 1 — 22/28, Semibold:** Tiêu đề section hoặc modal lớn.
- **Heading 2 — 18/24, Semibold:** Tiêu đề card và nhóm nội dung.
- **Body 1 — 16/24, Regular:** Nội dung đọc chính và mô tả sản phẩm.
- **Body 2 — 14/20, Regular:** Metadata, nội dung phụ và helper text.
- **Caption — 12/16, Regular:** Nhãn ngắn, thời gian, chú thích và trạng thái nhỏ.
- **Price — 20/26, Bold:** Giá tiền và tổng thanh toán, sử dụng tabular numbers.

Quy tắc:

- Tiêu đề ngắn, trực tiếp và ưu tiên động từ khi mô tả hành động.
- Giá, deadline, số tiền và countdown dùng chữ số tabular để tránh thay đổi chiều rộng.
- Không dùng quá ba cấp độ typography trong cùng một card.
- Không dùng chữ nhỏ hơn 12px cho nội dung có ý nghĩa.
- Hạn chế viết hoa toàn bộ; chỉ dùng cho nhãn kỹ thuật rất ngắn khi cần thiết.

## Layout

Hệ thống sử dụng **8-point grid**, với bước 4px cho căn chỉnh vi mô.

Spacing scale:

- `4px`: Khoảng cách vi mô giữa biểu tượng và nhãn.
- `8px`: Khoảng cách nhỏ trong chip, badge hoặc nhóm metadata.
- `12px`: Padding compact và khoảng cách giữa các field liên quan.
- `16px`: Padding mặc định của card, section và màn hình mobile.
- `20px`: Khoảng cách trung gian cho nội dung có mật độ vừa.
- `24px`: Khoảng cách giữa các nhóm nội dung chính.
- `32px`: Khoảng cách section lớn.
- `40px`: Khoảng trống nhấn mạnh hoặc khu vực hero.
- `64px`: Khoảng cách cấp trang hoặc khoảng trắng trình bày.

Nguyên tắc bố cục:

- Mobile ưu tiên một cột và vùng chạm tối thiểu `44px`.
- Nội dung liên quan được gom trong card có padding `16px` hoặc `24px`.
- Mỗi màn hình chỉ có một CTA chính nổi bật.
- Dùng khoảng trắng để tạo phân cấp trước khi thêm đường viền hoặc shadow.
- Căn chỉnh nội dung theo cạnh trái; giá và dữ liệu dạng bảng có thể căn phải.
- Không làm card quá dày đặc; metadata ít quan trọng cần được rút gọn hoặc chuyển sang màn hình chi tiết.

## Elevation & Depth

TradeLink dùng shadow nhẹ để tách bề mặt, không dùng bóng đổ nặng hoặc hiệu ứng kính quá mức.

- **Small:** `0 1px 2px rgba(15, 23, 42, 0.05)` — chip nổi, input hoặc card compact.
- **Medium:** `0 4px 12px rgba(15, 23, 42, 0.08)` — card mặc định, bottom sheet và dropdown.
- **Large:** `0 12px 32px rgba(15, 23, 42, 0.12)` — modal, panel nổi và lớp giao diện cần ưu tiên cao.

Quy tắc:

- Nền trang dùng `background`; nội dung chính dùng `surface`.
- Ưu tiên border nhẹ và tonal contrast trước khi tăng shadow.
- Không chồng nhiều lớp shadow lớn trong cùng một viewport.
- Modal hoặc bottom sheet phải có một lớp elevation rõ ràng hơn nội dung nền.

## Shapes

Ngôn ngữ hình khối sử dụng góc bo mềm, thân thiện và hiện đại.

- **4px:** Điều khiển nhỏ, focus indicator hoặc chi tiết kỹ thuật.
- **8px:** Chip lớn, thumbnail nhỏ hoặc control compact.
- **12px:** Input, dropdown và card compact.
- **16px:** Card mặc định, app icon và bottom sheet.
- **20px:** Card nổi bật, modal hoặc khối nội dung premium.
- **Pill / 9999px:** Button, badge, segmented control và filter chip.

Quy tắc:

- Không pha trộn góc vuông sắc với card bo tròn trong cùng một nhóm giao diện.
- Avatar và icon trạng thái có thể dùng hình tròn.
- Logo phải giữ nguyên tỷ lệ và khoảng hở bên trong biểu tượng liên kết.
- Border mặc định mảnh và trung tính; không dùng đường viền đậm nếu shadow hoặc màu nền đã đủ phân cấp.

## Components

### Logo and app icon

- Logo gồm biểu tượng liên kết xanh dương–teal và wordmark `TradeLink` màu Dark.
- App icon chỉ dùng biểu tượng, đặt trên nền Surface với bo góc 16px.
- Clear space tối thiểu quanh logo bằng chiều dày nét của biểu tượng.
- Không thêm slogan, badge hoặc icon phụ bên trong app icon.

### Buttons

- **Primary:** Nền Primary, chữ trắng, bo pill, cao 48px.
- **Secondary:** Nền trắng, chữ và border Primary.
- **Tertiary:** Không nền; dùng chữ Primary cho hành động ít ưu tiên.
- **Destructive:** Nền Error, chữ trắng; luôn yêu cầu xác nhận cho hành động không thể hoàn tác.
- Button phải có trạng thái default, hover/pressed, loading, disabled và focus.
- Nhãn button dùng động từ rõ ràng như `Thanh toán an toàn`, `Đăng tin`, `Xác nhận`.

### Inputs

- Cao mặc định 48px, bo 12px, nền trắng và border subtle.
- Focus dùng border Primary và focus ring dễ nhận biết.
- Error dùng border Error, icon cảnh báo và helper text; không chỉ đổi màu border.
- Label luôn hiển thị khi field chứa dữ liệu; placeholder không thay thế label.

### Cards

- Card mặc định dùng Surface, bo 16px, padding 16px và Medium shadow.
- Card compact dùng bo 12px, padding 12px và Small shadow.
- Card nổi bật dùng bo 20px, padding 24px và Large shadow.
- Card giao dịch phải ưu tiên trạng thái, hành động tiếp theo, deadline và số tiền.

### Chips and status badges

- Dùng dạng pill với padding ngang 8–12px.
- Mọi trạng thái phải có nhãn chữ và có thể có icon hỗ trợ.
- `Payment Held` sử dụng teal đậm; `Success` dùng xanh lá; `Warning` dùng amber; `Error` dùng đỏ.
- Không dùng badge cho nội dung mô tả dài.

### Iconography

- Icon dạng line, kích thước chuẩn `24px`.
- Stroke `2px`, đầu nét và điểm nối bo tròn.
- Filled icon chỉ dùng cho trạng thái điều hướng đang hoạt động hoặc trạng thái cần nhấn mạnh.
- Các biểu tượng phải quen thuộc, dễ nhận biết và có nhãn hỗ trợ khi ý nghĩa không rõ ràng.
- Icon quan trọng phải có vùng chạm tối thiểu 44×44px dù glyph chỉ 24px.

### Accessibility and states

- Tất cả control tương tác phải có focus state.
- Màu chữ và nền phải đạt WCAG AA.
- Không dùng màu sắc làm tín hiệu duy nhất.
- Disabled state vẫn phải đọc được nhưng không cạnh tranh với hành động khả dụng.
- Loading state giữ nguyên kích thước component để tránh layout shift.

## Do's and Don'ts

- **Do** dùng Primary cho hành động quan trọng nhất trên màn hình.
- **Do** dùng Trust Teal và Payment Held nhất quán cho ngữ cảnh bảo vệ giao dịch.
- **Do** giữ hệ thống spacing theo bước 4px/8px.
- **Do** sử dụng đầy đủ dấu tiếng Việt và kiểm tra hiển thị trên mọi nền tảng.
- **Do** kết hợp màu trạng thái với icon và nhãn chữ.
- **Do** giữ logo nguyên tỷ lệ và đúng thứ tự màu xanh dương–teal.
- **Do** ưu tiên khoảng trắng, hierarchy và nội dung ngắn gọn.
- **Don't** dùng màu semantic chỉ để trang trí.
- **Don't** dùng quá nhiều CTA Primary trên cùng một màn hình.
- **Don't** dùng shadow lớn cho mọi card.
- **Don't** dùng text xám nhạt cho giá, deadline hoặc trạng thái quan trọng.
- **Don't** trộn nhiều phong cách icon, độ dày stroke hoặc bán kính bo góc tùy ý.
- **Don't** kéo giãn, nghiêng, xoay hoặc thêm hiệu ứng 3D vào logo.
- **Don't** dùng neon, glassmorphism nặng hoặc thẩm mỹ crypto/fintech quá aggressive.
