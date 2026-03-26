import json, urllib.request, urllib.parse
text = "1Password is a password manager that allows you to store and manage your passwords securely."
query = urllib.parse.quote(text)
url = f'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=zh-CN&dt=t&q={query}'
data = json.load(urllib.request.urlopen(url, timeout=20))
result = ''.join(piece[0] for piece in data[0] if piece and piece[0])
print(result)
print(result.encode('utf-8'))
print([hex(ord(ch)) for ch in result[-5:]])
print([ord(ch) for ch in result[-2:]])
