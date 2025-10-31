# AI Crop Analysis gRPC Service

Python gRPC server for AI-powered crop analysis.

## Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Generate gRPC Code
```bash
python -m grpc_tools.protoc -I./protos --python_out=. --grpc_python_out=. ./protos/crop_analysis.proto
```

This will generate:
- `protos/crop_analysis_pb2.py`
- `protos/crop_analysis_pb2_grpc.py`

### 3. Run Server
```bash
python server.py
```

Server will start on port `50051` (configurable via `GRPC_PORT` environment variable).

## Environment Variables

- `GRPC_PORT`: Port to listen on (default: 50051)
- `MAX_WORKERS`: Max worker threads (default: 10)

## Testing

Use the Node.js client in `backend/services/aiService.js` or test with `grpcurl`:

```bash
grpcurl -plaintext localhost:50051 crop_analysis.CropAnalysisService/HealthCheck
```

## Note

Currently returns mock responses. Replace `_generate_mock_diagnosis()` in `server.py` with actual AI model inference.


